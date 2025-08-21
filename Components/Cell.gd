@tool
class_name Cell
extends Control

@export var button: Button
@export var number: Label
@export var letter: Label
@export var lock: Control
@export var foreground_container: Container
@export var foreground: ColorRect
@export var background: ColorRect

var cell_data: CellData
var cell_state: CellState

var is_primary_selected: bool = false
var is_secondary_selected: bool = false
var index: int = 0
var coords: Vector2i = Vector2i.ZERO
var active_tween: Tween

var initial_forground_container_position: Vector2

signal selected(cell: Cell)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cell_state = CellState.new()
	await get_tree().process_frame # Wait for container layout to finish
	initial_forground_container_position = foreground_container.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _cell_pressed():
	# Don't handle the selection here. This is not the only way for a cell to be selected.
	selected.emit(self)

func primary_select():
	_cancel_tweens()
	var duration = 0.07
	active_tween = create_tween().set_parallel()
	active_tween.tween_property(foreground_container, "position", initial_forground_container_position + Vector2(0, -5), duration)
	active_tween.tween_property(foreground, "color", Color("d989c9"), duration)
	
	is_primary_selected = true
	is_secondary_selected = false

func secondary_select():
	# Primary select takes priority
	if (is_primary_selected):
		return
		
	_cancel_tweens()
	var duration = 0.07
	active_tween = create_tween().set_parallel()
	active_tween.tween_property(foreground_container, "position", initial_forground_container_position, duration)
	active_tween.tween_property(foreground, "color", Color("f8ddf4"), duration)
	
	is_secondary_selected = true
	is_primary_selected = false

func unselect():
	_cancel_tweens()
	var duration = 0.07
	active_tween = create_tween().set_parallel()
	active_tween.tween_property(foreground_container, "position", initial_forground_container_position, duration)
	active_tween.tween_property(foreground, "color", Color("f7f7f7"), duration)
	
	is_primary_selected = false
	is_secondary_selected = false

func set_letter(char: String):
	letter.text = char
	cell_state.current_letter = char

func update_state(state: CellState):
	cell_state = state
	letter.text = cell_state.current_letter

func setup(cell_data: CellData):
	self.cell_data = cell_data
	if (cell_data.type == Globals.CellType.OPEN):
		if (cell_data.number > 0):
			number.text = str(cell_data.number)
		else:
			number.text = ""
		#letter.text = cell_data.answer
	else:
		lock.visible = true

func _cancel_tweens():
	if (active_tween and active_tween.is_running()):
		active_tween.kill()
