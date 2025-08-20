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

signal clue_selected(clue: Clue)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	await get_tree().process_frame
	
	#Calculate the max scroll offset by trying to scroll by a large amount
	var initial_scroll_offset = scroll_container.scroll_vertical
	scroll_container.scroll_vertical = 1000000
	max_scroll_offset = scroll_container.scroll_vertical
	scroll_container.scroll_vertical = initial_scroll_offset
	
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
		new_clue.selected.connect(_on_clue_selected)
		new_clue.setup(clue)
		
		clues_parent.add_child(new_clue)
		clues.set(number, new_clue)

func _on_clue_selected(clue: Clue):
	clue_selected.emit(clue)
	
func get_clue(number: int):
	return clues.get(number)

func select_clue(number: int) -> Clue:
	var clue = clues.get(number)
	if (clue):
		clue.select()
		scroll_to_clue(clue)
		return clue
	return null
	
func scroll_to_clue(clue: Clue):
	if (active_tween):
		active_tween.kill()
	
	var scroll_offset = min(clue.position.y, max_scroll_offset)
	active_tween = create_tween()
	active_tween.tween_property(scroll_container, "scroll_vertical", scroll_offset, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
