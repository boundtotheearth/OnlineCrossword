@tool
class_name Crossword
extends PanelContainer

@export_multiline var debug_data: String = ""

@export var board: Board
@export var clues: Clues

var websocket_client: WebsocketClient

var crossword_data_raw: String
var crossword_data_json: Dictionary
var crossword_data: CrosswordData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	websocket_client = get_node("/root/Game/WebsocketClient")
	websocket_client.init.connect(_on_init)
	#_update_crossword()
	pass # Replace with function body.

func _on_init(data: InitPacket):
	crossword_data_json = data.crossword_data_json
	_update_crossword()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_crossword():
	#crossword_data_raw = debug_data	
	var data_parser = CrosswordDataParser.new()
	data_parser.parse_json(crossword_data_json)
	crossword_data = data_parser.data
	#var result = data_parser.parse(crossword_data_raw)	
	#if (result == OK):
		#crossword_data = data_parser.data
	#else:
		#print("Failed to parse crossword data")
		#return
	#data_parser.free()
	
	if (board):
		board.setup(crossword_data)
		board.cell_selected.connect(_on_cell_selected)
	
	if (clues):
		clues.setup(crossword_data)
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

func _on_clue_selected(clue: Clue):
	clues.select_clue(clue)
	
	var cell_index = clue.clue_data.indexes[0]
	board.select_cell_index(cell_index, false, clue.clue_data.direction)
	
