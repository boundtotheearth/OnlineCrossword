class_name NetworkPacket
extends Resource

@export var type: String

func _init(type: String = ""):
	self.type = type

static func deserialize(data: Dictionary):
	pass
	
func serialize() -> Dictionary:
	return {
		'type': type
	}
