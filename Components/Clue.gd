@tool
class_name Clue
extends PanelContainer

@export var number: Label
@export var text: Label
@export var select_display: Control

var clue_data: ClueData
var is_selected: bool = false

signal pressed(clue: Clue)
signal selected(clue: Clue)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _clue_pressed():
	# Don't handle the selection here. This is not the only way for a clue to be selected.
	pressed.emit(self)
	
func setup(clue_data: ClueData):
	self.clue_data = clue_data
	number.text = str(clue_data.number) + "."
	text.text = clue_data.clue

func select():
	select_display.visible = true
	is_selected = true
	selected.emit(self)
	
func unselect():
	select_display.visible = false
	is_selected = false
