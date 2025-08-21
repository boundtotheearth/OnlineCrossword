class_name WebsocketClient
extends Node

# The URL we will connect to.
@export var websocket_url = "wss://echo.websocket.org"

# Our WebSocketClient instance.
var socket = WebSocketPeer.new()

signal init(data: InitPacket) # Initialize game using data from server
signal update_cell_state(data: UpdateCellStatePacket)
signal update_game_state(data: UpdateGameStatePacket)

func _ready():
	# Initiate connection to the given URL.
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		set_process(false)
	else:
		# Wait for the socket to connect.
		await get_tree().create_timer(2).timeout

func _process(_delta):
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	socket.poll()

	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()

	# WebSocketPeer.STATE_OPEN means the socket is connected and ready
	# to send and receive data.
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var packet = socket.get_packet().get_string_from_utf8()
			print("Got data from server: ", packet)
			process_packet(packet)

	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.

func process_packet(packet: String):
	var data = JSON.parse_string(packet)
	if (data):
		match(data['type']):
			'init':
				var init_packet = InitPacket.deserialize(data)
				init.emit(init_packet)
			'update_cell':
				var update_cell_packet = UpdateCellStatePacket.deserialize(data)
				update_cell_state.emit(update_cell_packet)

func send_packet(packet: NetworkPacket):
	send_dict(packet.serialize())

func send_dict(packet: Dictionary):
	socket.send_text(JSON.stringify(packet))
