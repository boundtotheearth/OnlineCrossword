@tool
class_name Clues
extends PanelContainer

@export var across_clues: ClueContainer
@export var down_clues: ClueContainer

var selected_clue: Clue

signal clue_selected(clue: Clue)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func setup(crossword_data: CrosswordData):
	var across_clue_data: Dictionary[int, ClueData] = {}
	var down_clue_data: Dictionary[int, ClueData] = {}
	for clue in crossword_data.clues:
		if (clue.direction == Globals.Direction.ACROSS):
			across_clue_data.set(clue.number, clue)
		elif (clue.direction == Globals.Direction.DOWN):
			down_clue_data.set(clue.number, clue)
	across_clues.setup(across_clue_data)
	down_clues.setup(down_clue_data)
	
	across_clues.clue_selected.connect(_on_clue_selected)
	down_clues.clue_selected.connect(_on_clue_selected)

func select_clue(clue: Clue):
	select_clue_number_direction(clue.clue_data.number, clue.clue_data.direction)

func select_clue_number_direction(number: int, direction: Globals.Direction):
	if (selected_clue):
		selected_clue.unselect()
	
	var clue_container: ClueContainer
	if (direction == Globals.Direction.ACROSS):
		clue_container = across_clues
	elif (direction == Globals.Direction.DOWN):
		clue_container = down_clues
	
	var clue = clue_container.select_clue(number)
	selected_clue = clue

func scroll_to_clue_number_direction(number: int, direction: Globals.Direction):
	var clue_container: ClueContainer
	if (direction == Globals.Direction.ACROSS):
		clue_container = across_clues
	elif (direction == Globals.Direction.DOWN):
		clue_container = down_clues
	
	var clue_to_select: Clue = clue_container.get_clue(number)
	clue_container.scroll_to_clue(clue_to_select)
	
func _on_clue_selected(clue: Clue):
	clue_selected.emit(clue)

func _smooth_scroll_to_control(control: Control):
	pass
