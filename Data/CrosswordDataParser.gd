class_name CrosswordDataParser
extends Object

var data: CrosswordData

func parse(raw_data: String) -> Error:
	var json = JSON.new()
	var result = json.parse(raw_data)
	
	var json_data: Dictionary
	if (result == OK):
		json_data = json.data
	else:
		print("Failed to parse crossword data")
		print(str(json.get_error_line()) + ": " + json.get_error_message())
		return FAILED
	
	data = CrosswordData.new()
	
	data.id = json_data.get("puzzleId", "ERROR")
	data.creator = json_data.get("creator", "ERROR")
	data.title = json_data.get("title", "ERROR")
	
	var width = json_data.get("width", 0)
	data.dimentions = Vector2i(width, width)
	
	data.cells = []
	var cells = json_data.get("cells", [])
	for cell in cells:
		var cell_data = CellData.new()
		cell_data.answer = cell.get("answer", "ERROR")
		cell_data.number = cell.get("number", 0)
		cell_data.type = _string_to_cell_type(cell.get("type", "Open"))
		data.cells.append(cell_data)
	
	data.clues = []
	var clues = json_data.get("words", [])
	var number = 1
	var prev_direction = -1
	for clue in clues:
		var clue_data = ClueData.new()
		clue_data.clue = clue.get("clue", "ERROR")
		clue_data.direction = _string_to_direction(clue.get("direction", "across"))
		
		if (clue_data.direction != prev_direction):
			number = 1
		clue_data.number = number
		prev_direction = clue_data.direction
		number += 1
		
		data.clues.append(clue_data)
	
	return OK

func _string_to_direction(string: String) -> Globals.Direction:
	match(string.to_lower()):
		"across":
			return Globals.Direction.ACROSS
		"down":
			return Globals.Direction.DOWN
			
	return Globals.Direction.ACROSS
	
func _string_to_cell_type(string: String) -> Globals.CellType:
	match(string.to_lower()):
		"locked":
			return Globals.CellType.LOCKED
		"":
			return Globals.CellType.OPEN
			
	return Globals.CellType.OPEN
