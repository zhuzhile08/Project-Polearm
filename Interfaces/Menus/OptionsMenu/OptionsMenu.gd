extends InterfaceState


signal onGameOptionsPressed
signal onVideoOptionsPressed
signal onAudioOptionsPressed
signal onControllerOptionsPressed
signal onKeyboardOptionsPressed

func _on_game_pressed() -> void:
	onGameOptionsPressed.emit()

func _on_video_pressed() -> void:
	onVideoOptionsPressed.emit()

func _on_audio_pressed() -> void:
	onAudioOptionsPressed.emit()

func _on_controller_pressed() -> void:
	onControllerOptionsPressed.emit()

func _on_keyboard_pressed() -> void:
	onKeyboardOptionsPressed.emit()
