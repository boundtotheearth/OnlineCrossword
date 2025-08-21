class_name UpdateGameStatePacket
extends NetworkPacket

@export var cell_states: Array[CellState]

func _init() -> void:
	self.type = "update_game_state"
	pass

static func deserialize(data: Dictionary) -> UpdateCellStatePacket:
	var instance = UpdateCellStatePacket.new()
	return instance
	
func serialize() -> Dictionary:
	return super.serialize().merged(
		{ },
		true
	)
