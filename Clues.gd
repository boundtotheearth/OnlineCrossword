@tool
class_name Clues
extends PanelContainer

@export var across_clues_container: ClueContainer
@export var down_clues_container: ClueContainer

var selected_clue: Clue

signal clue_pressed(clue: Clue)
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
	
	across_clues_container.setup(across_clue_data)
	down_clues_container.setup(down_clue_data)
	
	if (not across_clues_container.clue_pressed.is_connected(_on_clue_pressed)):
		across_clues_container.clue_pressed.connect(_on_clue_pressed)
	if (not down_clues_container.clue_pressed.is_connected(_on_clue_pressed)):
		down_clues_container.clue_pressed.connect(_on_clue_pressed)

func select_clue(clue: Clue):
	select_clue_number_direction(clue.clue_data.number, clue.clue_data.direction)

func select_clue_number_direction(number: int, direction: Globals.Direction):
	if (selected_clue):
		selected_clue.unselect()
		
	var clue_container: ClueContainer
	if (direction == Globals.Direction.ACROSS):
		clue_container = across_clues_container
	elif (direction == Globals.Direction.DOWN):
		clue_container = down_clues_container
	
	var clue = clue_container.get_clue(number)
	clue.select()
	clue_container.scroll_to_clue(clue)
	
	selected_clue = clue
	
	clue_selected.emit(clue)

func scroll_to_clue_number_direction(number: int, direction: Globals.Direction):
	var clue_container: ClueContainer
	if (direction == Globals.Direction.ACROSS):
		clue_container = across_clues_container
	elif (direction == Globals.Direction.DOWN):
		clue_container = down_clues_container
	
	var clue_to_select: Clue = clue_container.get_clue(number)
	clue_container.scroll_to_clue(clue_to_select)

func get_clue(number: int, direction: Globals.Direction) -> Clue:
	return get_clues_in_direction(direction).get(number)

func get_clues_in_direction(direction: Globals.Direction) -> Dictionary[int, Clue]:
	if (direction == Globals.Direction.ACROSS):
		return across_clues_container.clues
	elif (direction == Globals.Direction.DOWN):
		return down_clues_container.clues
	return {}

func _on_clue_pressed(clue: Clue):
	select_clue(clue)
	clue_pressed.emit(clue)
