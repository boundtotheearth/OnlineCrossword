class_name CurrentClue
extends PanelContainer

@export var clue_label: Label

var clue_data: ClueData

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_clue(clue_data: ClueData):
	self.clue_data = clue_data
	clue_label.text = clue_data.clue
