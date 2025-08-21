@tool
class_name Crossword
extends PanelContainer

@export_multiline var debug_data: String = ""
@export_tool_button("Debug Setup", "Callable") var debug_setup_button = _debug_setup

@export var board: Board
@export var clues: Clues

var websocket_client: WebsocketClient

var crossword_data: CrosswordData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (not Engine.is_editor_hint()):
		websocket_client = get_node("/root/Game/WebsocketClient")
		websocket_client.init.connect(_on_init)
		websocket_client.update_cell_state.connect(_on_update_cell_state)
		websocket_client.update_game_state.connect(_on_update_game_state)

func _on_init(data: InitPacket):
	var data_parser = CrosswordDataParser.new()
	data_parser.parse_json(data.puzzle_data)
	setup(data_parser.data)

func _on_update_cell_state(data: UpdateCellStatePacket):
	if (board):
		board.update_cell(data.index, data.letter)

func _on_update_game_state(data: UpdateGameStatePacket):
	pass

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

func _on_cell_selected(cell: Cell):
	board.select_cell(cell)
	
	var clue_data: ClueData = cell.cell_data.clues.get(board.selected_direction)
	if (clue_data):
		clues.select_clue_number_direction(clue_data.number, clue_data.direction)
		
		var other_direction: Globals.Direction
		if (clue_data.direction == Globals.Direction.ACROSS):
			other_direction = Globals.Direction.DOWN
		elif (clue_data.direction == Globals.Direction.DOWN):
			other_direction = Globals.Direction.ACROSS
		var other_clue_data: ClueData = cell.cell_data.clues.get(other_direction)
		clues.scroll_to_clue_number_direction(other_clue_data.number, other_direction)
	else:
		# Edge case: Cell only has clue in 1 direction
		var number = cell.cell_data.clues.values()[0].number
		var direction = cell.cell_data.clues.keys()[0]
		board.select_cell(cell, false, direction)
		clues.select_clue_number_direction(cell.cell_data.number, board.selected_direction)

func _on_cell_updated(cell: Cell):
	var update_cell_packet = UpdateCellStatePacket.new(
		cell.index,
		cell.cell_state
	)
	websocket_client.send_packet(update_cell_packet)

func _on_clue_selected(clue: Clue):
	clues.select_clue(clue)
	
	var cell_index = clue.clue_data.indexes[0]
	board.select_cell_index(cell_index, false, clue.clue_data.direction)
	
