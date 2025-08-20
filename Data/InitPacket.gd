class_name InitPacket
extends Resource

@export var crossword_data_json: Dictionary

func parse(packet: Dictionary):
	crossword_data_json = packet.get('crossword_data', {})
