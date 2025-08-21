class_name UpdateGameStatePacket
extends NetworkPacket

@export var cell_states: Array[CellState]

func _init(cell_states: Array[CellState] = []) -> void:
	self.type = "update_game_state"
	self.cell_states = cell_states

static func deserialize(data: Dictionary) -> UpdateGameStatePacket:
	var deserialized_cell_states: Array[CellState] = []
	var game_state = data.get("game_state", {})
	var cells = game_state.get("cells", [])
	for cell_state_data in cells:
		deserialized_cell_states.append(CellState.deserialize(cell_state_data))
	
	var instance = UpdateGameStatePacket.new(deserialized_cell_states)
	return instance
	
#func serialize() -> Dictionary:
	#var serialized_cell_states: Array[Dictionary] = []
	#for cell_state in cell_states:
		#serialized_cell_states.append(cell_state.serialize())
	#
	#return super.serialize().merged(
		#{
			#"cell_states": serialized_cell_states
		#},
		#true
	#)
