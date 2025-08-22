@tool
class_name ClueContainer
extends PanelContainer

@export var header_label: Label :
	set(value):
		header_label = value
		_update_header()
		
@export var header_text: String = "PLACEHOLDER NAME" :
	set(value):
		header_text = value
		_update_header()

@export var clues_parent: Container
@export var scroll_container: ScrollContainer
@export var clue_instance: PackedScene

var clue_datas: Dictionary[int, ClueData] # Clues can skip numbers
var clues: Dictionary[int, Clue]
var max_scroll_offset: float = 0
var active_tween: Tween

signal clue_pressed(clue: Clue)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(clue_datas: Dictionary[int, ClueData]):
	self.clue_datas = clue_datas
	_update_clues()

func _update_header():
	if (header_label):
			header_label.text = header_text

func _update_clues():
	for child in clues_parent.get_children():
		clues_parent.remove_child(child)
		child.queue_free()
	
	for number in clue_datas:
		var clue = clue_datas[number]
		var new_clue = clue_instance.instantiate() as Clue
		new_clue.pressed.connect(_on_clue_pressed)
		new_clue.setup(clue)
		
		clues_parent.add_child(new_clue)
		clues.set(number, new_clue)
	
	#Calculate the max scroll offset by trying to scroll by a large amount
	await get_tree().process_frame #Wait for layout calculations to finish
	var initial_scroll_offset = scroll_container.scroll_vertical
	scroll_container.scroll_vertical = 1000000
	max_scroll_offset = scroll_container.scroll_vertical
	scroll_container.scroll_vertical = initial_scroll_offset

func _on_clue_pressed(clue: Clue):
	clue_pressed.emit(clue)

func get_clue(number: int):
	return clues.get(number)

func scroll_to_clue(clue: Clue):
	if (active_tween):
		active_tween.kill()

	var position_offset = clue.global_position.y - scroll_container.global_position.y
	if (position_offset > 0 and position_offset < scroll_container.size.y - clue.size.y):
		# Clue Already Visible in Scroll Container
		return

	var scroll_offset = min(clue.position.y, max_scroll_offset)
	active_tween = create_tween()
	active_tween.tween_property(scroll_container, "scroll_vertical", scroll_offset, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
