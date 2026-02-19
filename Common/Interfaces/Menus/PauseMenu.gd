extends Control

# Signals that get redirected to the Interface Controller
signal _continue
signal _open_options
signal _open_main_menu


func _ready() -> void:
	$MarginContainer/VBoxContainer/Continue.grab_focus() # The "Continue" button is imediately highlighted when the Node opens
	
func _on_continue_pressed() -> void:
	_continue.emit()


func _on_options_pressed() -> void:
	_open_options.emit()


func _on_main_menu_pressed() -> void:
	_open_main_menu.emit()
