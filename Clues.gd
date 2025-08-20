@tool
class_name Clues
extends PanelContainer

@export var across_clues: ClueContainer
@export var down_clues: ClueContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func setup(crossword_data: CrosswordData):
	var across_clue_data: Array[ClueData] = []
	var down_clue_data: Array[ClueData] = []
	for clue in crossword_data.clues:
		if (clue.direction == Globals.Direction.ACROSS):
			across_clue_data.append(clue)
		elif (clue.direction == Globals.Direction.DOWN):
			down_clue_data.append(clue)
	across_clues.setup(across_clue_data)
	down_clues.setup(down_clue_data)
