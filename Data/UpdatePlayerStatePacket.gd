class_name UpdatePlayerStatePacket
extends NetworkPacket

@export var player_state: PlayerState

func _init(player_state: PlayerState = null) -> void:
	super("update_player_state")
	self.player_state = player_state

static func deserialize(data: Dictionary) -> UpdatePlayerStatePacket:
	var instance = UpdatePlayerStatePacket.new(
		PlayerState.deserialize_make(data['player_state'])
	)
	return instance
	
func serialize() -> Dictionary:
	return super.serialize().merged(
		{
			'player_state': player_state.serialize()
		},
		true
	)
