@tool
class_name ClueContainer
extends PanelContainer

@export var header_label: Label :
	set(value):
		header_label = value
		_update_header()
		
@export var header_text: String = "PLACEHOLDER NAME" :
	set(value):
		header_text = value
		_update_header()

@export var clues_parent: Container
@export var clue_instance: PackedScene

var clues: Array[ClueData]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(clues: Array[ClueData]):
	self.clues = clues
	_update_clues()

func _update_header():
	if (header_label):
			header_label.text = header_text

func _update_clues():
	for child in clues_parent.get_children():
		clues_parent.remove_child(child)
		child.queue_free()
	
	for clue in clues:
		var new_clue = clue_instance.instantiate() as Clue
		clues_parent.add_child(new_clue)
		new_clue.setup(clue)
	pass
