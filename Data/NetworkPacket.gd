class_name NetworkPacket
extends Resource

@export var type: String
@export var sender_id: String

func _init(type: String = ""):
	self.type = type
	self.sender_id = Globals.player_state.id

static func deserialize(data: Dictionary):
	pass
	
func serialize() -> Dictionary:
	return {
		'type': type,
		'sender_id': sender_id
	}
