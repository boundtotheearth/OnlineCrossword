@tool
class_name Crossword
extends PanelContainer

@export_multiline var debug_data: String = ""
@export_tool_button("Debug Setup", "Callable") var debug_setup_button = _debug_setup

@export var board: Board
@export var clues: Clues
@export var current_clue: CurrentClue

var websocket_client: WebsocketClient

var crossword_data: CrosswordData
var selected_direction: Globals.Direction
var selected_cell: Cell

signal game_ready

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (not Engine.is_editor_hint()):
		websocket_client = get_node("/root/Game/WebsocketClient")
		websocket_client.init.connect(_on_init)
		websocket_client.update_cell_state.connect(_on_update_cell_state)
		websocket_client.update_game_state.connect(_on_update_game_state)
		
		Globals.start_game.connect(start_game)
		Globals.exit_game.connect(exit_game)

func _on_init(data: InitPacket):
	var data_parser = CrosswordDataParser.new()
	data_parser.parse_json(data.puzzle_data)
	setup(data_parser.data)
	Globals.game_ready.emit()

func _on_update_cell_state(data: UpdateCellStatePacket):
	if (board):
		board.update_cell(data.index, data.cell_state, false)

func _on_update_game_state(data: UpdateGameStatePacket):
	if (board):
		for i in range(data.cell_states.size()):
			board.update_cell(i, data.cell_states[i], false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _debug_setup():
	var data_parser = CrosswordDataParser.new()
	data_parser.parse_string(debug_data)
	setup(data_parser.data)

func setup(data: CrosswordData):
	self.crossword_data = data
	if (board):
		board.setup(crossword_data)
		if (not board.cell_selected.is_connected(_on_cell_selected)):
			board.cell_selected.connect(_on_cell_selected)
		if (not board.cell_updated.is_connected(_on_cell_updated)):
			board.cell_updated.connect(_on_cell_updated)
	
	if (clues):
		clues.setup(crossword_data)
		if (not clues.clue_selected.is_connected(_on_clue_selected)):
			clues.clue_selected.connect(_on_clue_selected)
		if (not clues.clue_pressed.is_connected(_on_clue_pressed)):
			clues.clue_pressed.connect(_on_clue_pressed)
	
	await get_tree().process_frame # Let layout calculations finish
	board.select_cell_index(0)

func start_game():
	websocket_client.start_connection()

func exit_game():
	websocket_client.close_connection()

func _on_cell_selected(cell: Cell, direction: Globals.Direction):
	selected_cell = cell
	selected_direction = direction
	var clue_data: ClueData = cell.cell_data.clues.get(direction)
	if (clue_data):
		clues.select_clue_number_direction(clue_data.number, clue_data.direction)
		
		var other_direction = Globals.get_other_direction(clue_data.direction)
		var other_clue_data: ClueData = cell.cell_data.clues.get(other_direction)
		clues.scroll_to_clue_number_direction(other_clue_data.number, other_direction)
	else:
		# Edge case: Cell only has clue in 1 direction
		var number = cell.cell_data.clues.values()[0].number
		var other_direction = cell.cell_data.clues.keys()[0]
		board.select_cell(cell, false, other_direction)
		clues.select_clue_number_direction(cell.cell_data.number, other_direction)

func _on_cell_updated(cell: Cell, should_broadcast: bool):
	if (should_broadcast):
		_broadcast_update_cell(cell)

func _on_clue_selected(clue: Clue):	
	current_clue.update_clue(clue.clue_data)

func _on_clue_pressed(clue: Clue):
	var cell_index = clue.clue_data.indexes[0]
	board.select_cell_index(cell_index, false, clue.clue_data.direction)

func _broadcast_update_cell(cell: Cell):
	var update_cell_packet = UpdateCellStatePacket.new(
		cell.index,
		cell.cell_state
	)
	websocket_client.send_packet(update_cell_packet)

func _input(event: InputEvent):
	if (event is InputEventKey and event.pressed):
		if (event.physical_keycode >= 65 and event.physical_keycode <= 90):
			if (selected_cell):
				var was_empty = selected_cell.is_empty()
				var input_char = OS.get_keycode_string(event.physical_keycode)
				
				board.update_cell(selected_cell.index, CellState.new(input_char), true)
				
				var next_cell: Cell
				if (was_empty):
					next_cell = _get_next_empty_cell(selected_cell)
				else:
					next_cell = _get_next_cell_in_clue(selected_cell, selected_direction)
				board.select_cell(next_cell)

		if (event.physical_keycode == KEY_BACKSPACE):
			if (selected_cell):
				board.update_cell(selected_cell.index, CellState.new(""), true)
				var next_direction: Vector2i = -(Globals.direction_to_vector(selected_direction))
				var next_cell: Cell = board.get_open_cell_in_direction(selected_cell.coords, next_direction, 1)
				if (next_cell):
					board.select_cell(next_cell)
				else:
					board.select_cell(selected_cell, false, selected_direction)
		if (event.physical_keycode == KEY_ESCAPE):
			exit_game()
			
	if (selected_cell):
		if (event.is_action_pressed("ui_left")):
			if (selected_direction == Globals.Direction.DOWN):
				board.select_cell(selected_cell)
			else:
				var next_cell = board.get_open_cell_in_direction(selected_cell.coords, Vector2i(-1, 0), crossword_data.dimentions.x)
				if (next_cell):
					board.select_cell(next_cell)
		if (event.is_action_pressed("ui_right")):
			if (selected_direction == Globals.Direction.DOWN):
				board.select_cell(selected_cell)
			else:
				var next_cell = board.get_open_cell_in_direction(selected_cell.coords, Vector2i(1, 0), crossword_data.dimentions.x)
				if (next_cell):
					board.select_cell(next_cell)
		if (event.is_action_pressed("ui_up")):
			if (selected_direction == Globals.Direction.ACROSS):
				board.select_cell(selected_cell)
			else:
				var next_cell = board.get_open_cell_in_direction(selected_cell.coords, Vector2i(0, -1), crossword_data.dimentions.y)
				if (next_cell):
					board.select_cell(next_cell)
		if (event.is_action_pressed("ui_down")):
			if (selected_direction == Globals.Direction.ACROSS):
				board.select_cell(selected_cell)
			else:
				var next_cell = board.get_open_cell_in_direction(selected_cell.coords, Vector2i(0, 1), crossword_data.dimentions.y)
				if (next_cell):
					board.select_cell(next_cell)

func _get_next_empty_cell(cell: Cell) -> Cell:
	var other_direction = Globals.get_other_direction(selected_direction)
	var next_cell: Cell = null
	next_cell = _get_next_empty_cell_in_clue(cell, selected_direction)
	if (next_cell):
		return next_cell
	
	next_cell = _get_next_empty_clue_cell(cell, selected_direction)
	if (next_cell):
		return next_cell
	
	next_cell = _get_next_empty_clue_cell(cell, other_direction)
	if (next_cell):
		return next_cell

	#If code reaches here, there are no more empty cells?
	return null

func _get_next_cell_in_clue(cell: Cell, direction) -> Cell:
	var clue: ClueData = cell.cell_data.clues.get(direction)
	var i = clue.indexes.find(cell.index)
	var next_i = (i + 1) % clue.indexes.size()
	var next_cell: Cell = board.get_cell(clue.indexes[next_i])
	return next_cell

func _get_next_empty_cell_in_clue(cell: Cell, direction: Globals.Direction) -> Cell:
	var next_cell: Cell = cell
	while (not next_cell.is_empty()):
		next_cell = _get_next_cell_in_clue(next_cell, direction)
		if (next_cell == cell): # Looped back
			return null
	return next_cell

## Get the first empty cell from the next clue in the direction that contains empty cells
func _get_next_empty_clue_cell(cell: Cell, direction: Globals.Direction) -> Cell:
	var clues_in_direction = clues.get_clues_in_direction(direction)
	var clue_numbers = clues_in_direction.keys()
	var number = cell.cell_data.clues.get(direction).number
	var i = clue_numbers.find(number)
	for i_offset in range(clue_numbers.size()):
		var next_i = (i + i_offset) % clue_numbers.size()
		var next_number = clue_numbers[next_i]
		var clue: Clue = clues_in_direction[next_number]
		var first_cell = board.get_cell(clue.clue_data.indexes[0])
		var next_cell = _get_next_empty_cell_in_clue(first_cell, direction)
		if (next_cell):
			return next_cell
			
	return null
