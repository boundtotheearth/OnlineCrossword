@tool
class_name Crossword
extends PanelContainer

@export_multiline var debug_data: String = ""

@export var board: Board
@export var clues: Clues

var crossword_data_raw: String
var crossword_data_json: Dictionary
var crossword_data: CrosswordData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_crossword()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _update_crossword():
	crossword_data_raw = debug_data
	
	var data_parser = CrosswordDataParser.new()
	var result = data_parser.parse(crossword_data_raw)	
	if (result == OK):
		crossword_data = data_parser.data
	else:
		print("Failed to parse crossword data")
		return
	data_parser.free()
	
	if (board):
		board.setup(crossword_data)
		board.cell_selected.connect(_on_cell_selected)
	
	if (clues):
		clues.setup(crossword_data)

func _on_cell_selected(cell: Cell):
	board.select_cell(cell)
	#clues.select_clue(clue)
	
