@tool
class_name Board
extends Control

@export var cell_instance: PackedScene

@export var cell_size_default: int = 24
@export_tool_button("Create Board", "Callable") var create_board_button = _create_board

var crossword_data: CrosswordData
var cells: Array[Cell] = []

var primary_selected_cell: Cell
var secondary_selected_cells: Dictionary[Cell, bool]
var selected_direction: Globals.Direction = Globals.Direction.ACROSS

signal cell_selected(cell: Cell)
signal cell_updated(cell: Cell)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func setup(data: CrosswordData):
	self.crossword_data = data
	_create_board()

func select_cell_index(index: int, toggle: bool = true, direction: Globals.Direction = Globals.Direction.ACROSS):
	if (index >= 0 and index < cells.size()):
		select_cell(cells[index], toggle, direction)

func select_cell(cell: Cell, toggle: bool = true, direction: Globals.Direction = Globals.Direction.ACROSS):
	if (primary_selected_cell != cell):
		if (primary_selected_cell):
			primary_selected_cell.unselect()
		cell.primary_select()
		primary_selected_cell = cell
	else:
		# Only toggle direction when selecting same cell
		if (toggle):
			if (selected_direction == Globals.Direction.ACROSS):
				selected_direction = Globals.Direction.DOWN
			elif (selected_direction == Globals.Direction.DOWN):
				selected_direction = Globals.Direction.ACROSS
	
	if (not toggle):
		selected_direction = direction
		
	for already_selected_cell in secondary_selected_cells:
		if (already_selected_cell != primary_selected_cell):
			already_selected_cell.unselect()
	secondary_selected_cells.clear()
	
	if (selected_direction == Globals.Direction.ACROSS):
		var next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(1, 0), 1)
		while (next_cell):
			next_cell.secondary_select()
			secondary_selected_cells.set(next_cell, true)
			next_cell = _get_open_cell_in_direction(next_cell.coords, Vector2i(1, 0), 1)
		
		next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(-1, 0), 1)
		while (next_cell):
			next_cell.secondary_select()
			secondary_selected_cells.set(next_cell, true)
			next_cell = _get_open_cell_in_direction(next_cell.coords, Vector2i(-1, 0), 1)
	elif (selected_direction == Globals.Direction.DOWN):		
		var next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(0, 1), 1)
		while (next_cell):
			next_cell.secondary_select()
			secondary_selected_cells.set(next_cell, true)
			next_cell = _get_open_cell_in_direction(next_cell.coords, Vector2i(0, 1), 1)
		
		next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(0, -1), 1)
		while (next_cell):
			next_cell.secondary_select()
			secondary_selected_cells.set(next_cell, true)
			next_cell = _get_open_cell_in_direction(next_cell.coords, Vector2i(0, -1), 1)

func update_cell(index: int, letter: String, emit: bool = false):
	if (index >= 0 and index < cells.size()):
		var cell: Cell = cells[index]
		cell.set_letter(letter)
		if (emit):
			cell_updated.emit(cell)

func _create_board():	
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	var dimentions = crossword_data.dimentions
	var center_position = global_position
	var board_size = Vector2(dimentions.x, dimentions.y) * cell_size_default
	var start_position = center_position - (board_size / 2)
	cells.resize(dimentions.x * dimentions.y)
	for y in range(dimentions.y):
		for x in range(dimentions.x):
			var cell_index = y * dimentions.x + x
			var new_cell = cell_instance.instantiate() as Cell
			add_child(new_cell)
			new_cell.name = "Cell%d" % cell_index
			new_cell.size = Vector2(cell_size_default, cell_size_default)
			new_cell.global_position = start_position + Vector2(x, y) * cell_size_default
			new_cell.index = cell_index
			new_cell.coords = Vector2i(x, y)
			new_cell.setup(crossword_data.cells[cell_index])
			new_cell.selected.connect(_on_cell_selected)
			
			cells[cell_index] = new_cell
	return

func _on_cell_selected(cell: Cell):
	cell_selected.emit(cell)

func _on_cell_updated(cell: Cell):
	cell_updated.emit(cell)

func _input(event: InputEvent):
	if (event is InputEventKey and event.pressed):
		if (event.physical_keycode >= 65 and event.physical_keycode <= 90):
			if (primary_selected_cell):
				var input_char = OS.get_keycode_string(event.physical_keycode)
				update_cell(primary_selected_cell.index, input_char, true)
				var next_direction: Vector2i = Globals.direction_to_vector(selected_direction)
				var next_cell: Cell = _get_open_cell_in_direction(primary_selected_cell.coords, next_direction, 1)
				if (next_cell):
					_on_cell_selected(next_cell)
	
		if (event.physical_keycode == KEY_BACKSPACE):
			if (primary_selected_cell):
				update_cell(primary_selected_cell.index, "", true)
				var next_direction: Vector2i = -(Globals.direction_to_vector(selected_direction))
				var next_cell: Cell = _get_open_cell_in_direction(primary_selected_cell.coords, next_direction, 1)
				if (next_cell):
					_on_cell_selected(next_cell)
	
	if (event.is_action_pressed("ui_left")):
		if (selected_direction == Globals.Direction.DOWN):
			_on_cell_selected(primary_selected_cell)
		else:
			var next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(-1, 0), crossword_data.dimentions.x)
			if (next_cell):
				_on_cell_selected(next_cell)
	if (event.is_action_pressed("ui_right")):
		if (selected_direction == Globals.Direction.DOWN):
			_on_cell_selected(primary_selected_cell)
		else:
			var next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(1, 0), crossword_data.dimentions.x)
			if (next_cell):
				_on_cell_selected(next_cell)
	if (event.is_action_pressed("ui_up")):
		if (selected_direction == Globals.Direction.ACROSS):
			_on_cell_selected(primary_selected_cell)
		else:
			var next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(0, -1), crossword_data.dimentions.y)
			if (next_cell):
				_on_cell_selected(next_cell)
	if (event.is_action_pressed("ui_down")):
		if (selected_direction == Globals.Direction.ACROSS):
			_on_cell_selected(primary_selected_cell)
		else:
			var next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(0, 1), crossword_data.dimentions.y)
			if (next_cell):
				_on_cell_selected(next_cell)

func _get_open_cell_in_direction(start: Vector2i, direction: Vector2i, distance: int) -> Cell:
	var distance_covered = 0
	var next = start + direction
	var next_index = next.y * crossword_data.dimentions.x + next.x
	while (distance_covered < distance) and (next.x >= 0 and next.x < crossword_data.dimentions.x and next.y >= 0 and next.y < crossword_data.dimentions.y):
		distance_covered += 1
		next_index = next.y * crossword_data.dimentions.x + next.x
		if (cells[next_index].cell_data.type != Globals.CellType.LOCKED):
			return cells[next_index]
		else:
			next = next + direction
	
	return null
