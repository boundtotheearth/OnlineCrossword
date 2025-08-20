@tool
class_name Board
extends Control

@export var cell_instance: PackedScene

@export var cell_size_default: int = 24 :
	set(value):
		cell_size_default = value
		_create_board()

@export var dimentions: Vector2i = Vector2i.ZERO

@export_tool_button("Create Board", "Callable") var create_board_button = _create_board

var crossword_data: CrosswordData
var cells: Array[Cell] = []

var primary_selected_cell: Cell
var secondary_selected_cells: Dictionary[Cell, bool]
var selected_direction: Globals.Direction = Globals.Direction.ACROSS

signal cell_selected(cell: Cell)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func setup(crossword_data: CrosswordData):
	self.crossword_data = crossword_data
	self.dimentions = crossword_data.dimentions
	_create_board()

func select_cell(cell: Cell):
	if (primary_selected_cell != cell):
		if (primary_selected_cell):
			primary_selected_cell.unselect()
		cell.primary_select()
		primary_selected_cell = cell
	else:
		if (selected_direction == Globals.Direction.ACROSS):
			selected_direction = Globals.Direction.DOWN
		elif (selected_direction == Globals.Direction.DOWN):
			selected_direction = Globals.Direction.ACROSS
		
	for already_selected_cell in secondary_selected_cells:
		if (already_selected_cell != primary_selected_cell):
			already_selected_cell.unselect()
	secondary_selected_cells.clear()
	
	if (selected_direction == Globals.Direction.ACROSS):
		var next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(1, 0), 1)
		while (next_cell):
			next_cell.secondary_select()
			secondary_selected_cells.set(next_cell, true)
			next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(1, 0), 1)
		
		next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(-1, 0), 1)
		while (next_cell):
			next_cell.secondary_select()
			secondary_selected_cells.set(next_cell, true)
			next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(-1, 0), 1)
		
		#for x in range(primary_selected_cell.coords.x, dimentions.x):
			#var index = primary_selected_cell.coords.y * dimentions.x + x
			#if (cells[index].cell_data.type == Globals.CellType.LOCKED):
				#break
			#if (not cells[index].is_secondary_selected and not cells[index].is_primary_selected):
				#cells[index].secondary_select()
				#secondary_selected_cells.set(cells[index], true)
		#for x in range(primary_selected_cell.coords.x, -1, -1):
			#var index = primary_selected_cell.coords.y * dimentions.x + x
			#if (cells[index].cell_data.type == Globals.CellType.LOCKED):
				#break
			#if (not cells[index].is_secondary_selected and not cells[index].is_primary_selected):
				#cells[index].secondary_select()
				#secondary_selected_cells.set(cells[index], true)
	elif (selected_direction == Globals.Direction.DOWN):		
		for y in range(primary_selected_cell.coords.y, dimentions.y):
			var index = y * dimentions.x + primary_selected_cell.coords.x
			if (cells[index].cell_data.type == Globals.CellType.LOCKED):
				break
			if (not cells[index].is_secondary_selected and not cells[index].is_primary_selected):
				cells[index].secondary_select()
				secondary_selected_cells.set(cells[index], true)
		for y in range(primary_selected_cell.coords.y, -1, -1):
			var index = y * dimentions.x + primary_selected_cell.coords.x
			if (cells[index].cell_data.type == Globals.CellType.LOCKED):
				break
			if (not cells[index].is_secondary_selected and not cells[index].is_primary_selected):
				cells[index].secondary_select()
				secondary_selected_cells.set(cells[index], true)

func _create_board():	
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	var center_position = global_position
	var board_size = Vector2(dimentions.x, dimentions.y) * cell_size_default
	var start_position = center_position - (board_size / 2)
	cells.resize(dimentions.x * dimentions.y)
	for y in range(dimentions.y):
		for x in range(dimentions.x):
			var cell_index = y * dimentions.x + x
			var new_cell = cell_instance.instantiate() as Cell
			new_cell.name = "Cell%d" % cell_index
			new_cell.size = Vector2(cell_size_default, cell_size_default)
			new_cell.global_position = start_position + Vector2(x, y) * cell_size_default
			new_cell.index = cell_index
			new_cell.coords = Vector2i(x, y)
			if (crossword_data):
				new_cell.setup(crossword_data.cells[cell_index])
			new_cell.selected.connect(_on_cell_selected)
			add_child(new_cell)
			cells[cell_index] = new_cell
	return

func _on_cell_selected(cell: Cell):
	cell_selected.emit(cell)

func _input(event: InputEvent):
	if (event.is_action_pressed("ui_left")):
		if (selected_direction == Globals.Direction.DOWN):
			_on_cell_selected(primary_selected_cell)
		else:
			var next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(-1, 0), dimentions.x)
			if (next_cell):
				_on_cell_selected(next_cell)
	if (event.is_action_pressed("ui_right")):
		if (selected_direction == Globals.Direction.DOWN):
			_on_cell_selected(primary_selected_cell)
		else:
			var next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(1, 0), dimentions.x)
			if (next_cell):
				_on_cell_selected(next_cell)
	if (event.is_action_pressed("ui_up")):
		if (selected_direction == Globals.Direction.ACROSS):
			_on_cell_selected(primary_selected_cell)
		else:
			var next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(0, -1), dimentions.y)
			if (next_cell):
				_on_cell_selected(next_cell)
	if (event.is_action_pressed("ui_down")):
		if (selected_direction == Globals.Direction.ACROSS):
			_on_cell_selected(primary_selected_cell)
		else:
			var next_cell = _get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(0, 1), dimentions.y)
			if (next_cell):
				_on_cell_selected(next_cell)

func _get_open_cell_in_direction(start: Vector2i, direction: Vector2i, distance: int) -> Cell:
	var next = start + direction
	var next_index = next.y * dimentions.x + next.x
	while (next.x >= 0 and next.x < dimentions.x and next.y >= 0 and next.y < dimentions.y):
		next_index = next.y * dimentions.x + next.x
		if (cells[next_index].cell_data.type != Globals.CellType.LOCKED):
			return cells[next_index]
		else:
			next = next + direction
	
	return null
