@tool
class_name Clue
extends HBoxContainer

@export var number: Label
@export var text: Label

var clue_data: ClueData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func setup(clue_data: ClueData):
	self.clue_data = clue_data
	number.text = str(clue_data.number) + "."
	text.text = clue_data.clue
