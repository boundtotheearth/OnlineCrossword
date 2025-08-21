class_name InitPacket
extends NetworkPacket

@export var puzzle_data: Dictionary

func _init(puzzle_data: Dictionary = {}) -> void:
	self.type = "init"
	self.puzzle_data = puzzle_data

static func deserialize(packet: Dictionary) -> InitPacket:
	var instance = InitPacket.new(packet.get('puzzle_data', {}))
	return instance
