class_name CellState
extends Resource

@export var current_letter: String = ""

func _init(current_letter: String = ""):
	self.current_letter = current_letter

static func deserialize(data: Dictionary) -> CellState:
	return CellState.new(
		data['current_letter']
	)

func serialize() -> Dictionary:
	return {
		'current_letter': current_letter
	}
