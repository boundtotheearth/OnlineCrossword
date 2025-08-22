extends Panel

@export var InitialsLineEdit: LineEdit
@export var ColorButton: ColorPickerButton

var active_tween: Tween

func hide_screen():
	if (active_tween and active_tween.is_running()):
		active_tween.kill()

	active_tween = create_tween()
	active_tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 0.8)

func _on_play_button_pressed():
	hide_screen()
