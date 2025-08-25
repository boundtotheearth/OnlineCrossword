@tool
class_name Board
extends Control

@export var cells_parent: Control
@export var border: Control
@export var cell_instance: PackedScene

@export var cell_size_default: int = 24
@export_tool_button("Redraw Board", "Callable") var redraw_board_button = _create_board

var crossword_data: CrosswordData
var cells: Array[Cell] = []

var primary_selected_cell: Cell
var secondary_selected_cells: Dictionary[Cell, bool]
var selected_direction: Globals.Direction = Globals.Direction.ACROSS

signal cell_selected(cell: Cell, direction: Globals.Direction)
signal cell_updated(cell: Cell, should_broadcast: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func setup(data: CrosswordData):
	primary_selected_cell = null
	secondary_selected_cells.clear()
	selected_direction = Globals.Direction.ACROSS
	crossword_data = data
	_create_board()

func get_cell(index: int) -> Cell:
	if (index >= 0 and index < cells.size()):
		return cells[index]
	else:
		return null

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
		var next_cell = get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(1, 0), 1)
		while (next_cell):
			next_cell.secondary_select()
			secondary_selected_cells.set(next_cell, true)
			next_cell = get_open_cell_in_direction(next_cell.coords, Vector2i(1, 0), 1)
		
		next_cell = get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(-1, 0), 1)
		while (next_cell):
			next_cell.secondary_select()
			secondary_selected_cells.set(next_cell, true)
			next_cell = get_open_cell_in_direction(next_cell.coords, Vector2i(-1, 0), 1)
	elif (selected_direction == Globals.Direction.DOWN):		
		var next_cell = get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(0, 1), 1)
		while (next_cell):
			next_cell.secondary_select()
			secondary_selected_cells.set(next_cell, true)
			next_cell = get_open_cell_in_direction(next_cell.coords, Vector2i(0, 1), 1)
		
		next_cell = get_open_cell_in_direction(primary_selected_cell.coords, Vector2i(0, -1), 1)
		while (next_cell):
			next_cell.secondary_select()
			secondary_selected_cells.set(next_cell, true)
			next_cell = get_open_cell_in_direction(next_cell.coords, Vector2i(0, -1), 1)
	
	cell_selected.emit(primary_selected_cell, selected_direction)
	
func update_cell(index: int, cell_state: CellState, should_broadcast: bool):
	if (index >= 0 and index < cells.size()):
		var cell: Cell = cells[index]
		cell.update_state(cell_state)
		cell_updated.emit(cell, should_broadcast)

func _create_board():	
	for child in cells_parent.get_children():
		cells_parent.remove_child(child)
		child.queue_free()
	
	var dimentions = crossword_data.dimentions
	var center_position = global_position
	var board_size = Vector2(dimentions.x, dimentions.y) * cell_size_default
	var start_position = center_position - (board_size / 2)
	border.global_position = start_position
	border.size = board_size
	cells_parent.global_position = start_position
	cells_parent.size = board_size
	cells.resize(dimentions.x * dimentions.y)
	for y in range(dimentions.y):
		for x in range(dimentions.x):
			var cell_index = y * dimentions.x + x
			var new_cell = cell_instance.instantiate() as Cell
			cells_parent.add_child(new_cell)
			#new_cell.owner = cells_parent.owner
			new_cell.name = "Cell%d" % cell_index
			new_cell.size = Vector2(cell_size_default, cell_size_default)
			new_cell.global_position = start_position + Vector2(x, y) * cell_size_default
			new_cell.index = cell_index
			new_cell.coords = Vector2i(x, y)
			new_cell.setup(crossword_data.cells[cell_index])
			new_cell.pressed.connect(_on_cell_pressed)
			new_cell.selected.connect(_on_cell_selected)
			
			cells[cell_index] = new_cell
	return

func _on_cell_pressed(cell: Cell):
	select_cell(cell)

func _on_cell_selected(cell: Cell):
	pass

func get_open_cell_in_direction(start: Vector2i, direction: Vector2i, distance: int) -> Cell:
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
