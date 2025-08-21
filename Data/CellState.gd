class_name CellState
extends Resource

@export var current_letter: String = ""

static func deserialize() -> CellState:
	pass

func serialize() -> Dictionary:
	return {
		'current_letter': current_letter
	}
