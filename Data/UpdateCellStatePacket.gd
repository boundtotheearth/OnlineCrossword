class_name UpdateCellStatePacket
extends NetworkPacket

@export var index: int
@export var cell_state: CellState

func _init(index: int = 0, cell_state: CellState = null) -> void:
	self.type = "update_cell"
	self.index = index
	self.cell_state = cell_state

static func deserialize(data: Dictionary) -> UpdateCellStatePacket:
	var instance = UpdateCellStatePacket.new(
		data['index'],
		CellState.deserialize(data['cell_state'])
	)
	return instance
	
func serialize() -> Dictionary:
	return super.serialize().merged(
		{
			'index': index,
			'cell_state': cell_state.serialize()
		},
		true
	)
