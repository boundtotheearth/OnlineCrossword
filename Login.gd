extends Panel

@export var NameLineEdit: LineEdit
@export var ColorButton: ColorPickerButton

var active_tween: Tween

func _ready() -> void:
	_update_player()

func hide_screen():
	if (active_tween and active_tween.is_running()):
		active_tween.kill()
	
	propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])
	active_tween = create_tween()
	active_tween.tween_property(self, "modulate", Color(0.5, 0.5, 0.5, 0), 0.5)
	active_tween.tween_callback(func(): self.visible = false)

func show_screen():
	if (active_tween and active_tween.is_running()):
		active_tween.kill()
	
	self.visible = true
	propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_STOP])
	active_tween = create_tween()
	active_tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)

func _on_play_button_pressed():
	hide_screen()

func _update_player():
	NameLineEdit.text = Globals.player_state.name
	ColorButton.color = Globals.player_state.color
