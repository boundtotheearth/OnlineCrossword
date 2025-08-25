extends Panel

@export var NameLineEdit: LineEdit
@export var ColorButton: ColorPickerButton
@export var PlayButton: Button

var active_tween: Tween
var original_play_text: String = ""

func _ready() -> void:
	original_play_text = PlayButton.text
	_update_player()
	Globals.exit_game.connect(show_screen)
	Globals.game_ready.connect(hide_screen)

func hide_screen():
	if (active_tween and active_tween.is_running()):
		active_tween.kill()
	
	propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_IGNORE])
	active_tween = create_tween()
	active_tween.tween_property(self, "modulate", Color(0.5, 0.5, 0.5, 0), 0.5)
	active_tween.tween_callback(func(): self.visible = false)

func show_screen():
	PlayButton.text = original_play_text
	
	if (active_tween and active_tween.is_running()):
		active_tween.kill()
	
	self.visible = true
	propagate_call("set_mouse_filter", [Control.MOUSE_FILTER_STOP])
	active_tween = create_tween()
	active_tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)

func _on_play_button_pressed():
	#hide_screen()
	PlayButton.text = "Loading..."
	Globals.start_game.emit()

func _update_player():
	NameLineEdit.text = Globals.player_state.name
	ColorButton.color = Globals.player_state.color
