@tool
extends Control

@export var cell_instance: PackedScene

@export var cell_size_default: int = 24 :
	set(value):
		cell_size_default = value
		_create_board()

@export var dimentions: Vector2i = Vector2i.ZERO :
	set(value):
		dimentions = value
		_create_board()

@export_tool_button("Create Board", "Callable") var create_board_button = _create_board
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _create_board():	
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	var center_position = global_position
	var board_size = Vector2(dimentions.x, dimentions.y) * cell_size_default
	var start_position = center_position - (board_size / 2)
	for x in range(dimentions.x):
		for y in range(dimentions.y):
			var cell_index = Vector2i(x, y)
			var new_cell = cell_instance.instantiate() as Control
			new_cell.name = "Cell%.0v" % cell_index
			add_child(new_cell)
			new_cell.size = Vector2(cell_size_default, cell_size_default)
			new_cell.global_position = start_position + Vector2(cell_index * cell_size_default)
	
	return
