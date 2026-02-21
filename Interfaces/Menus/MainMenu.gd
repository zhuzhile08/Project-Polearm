extends Control

# Signals that get redirected to the Interface Controller
signal startGamePressed
signal newGamePressed
signal openOptionsPressed
signal quitGamePressed

func _on_continue_pressed() -> void:
	startGamePressed.emit()

func _on_new_game_pressed() -> void:
	newGamePressed.emit()

func _on_options_pressed() -> void:
	openOptionsPressed.emit()

func _on_exit_game_pressed() -> void:
	quitGamePressed.emit()
