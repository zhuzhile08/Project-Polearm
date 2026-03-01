extends InterfaceState

# Signals that get redirected to the Interface Controller
signal continuePressed
signal openOptionsPressed
signal openMainMenuPressed

func _on_continue_pressed() -> void:
	continuePressed.emit()

func _on_options_pressed() -> void:
	openOptionsPressed.emit()

func _on_main_menu_pressed() -> void:
	openMainMenuPressed.emit()
