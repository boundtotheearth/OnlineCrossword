extends Button

func _on_pressed():
	Globals.exit_game.emit()
