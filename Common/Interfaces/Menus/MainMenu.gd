extends Control

# Signals that get redirected to the Interface Controller
signal _start_game
signal _new_game
signal _open_options
signal _exit_game

func _ready() -> void:
	$HBoxContainer/MarginContainer/VBoxContainer/Continue.grab_focus() # The "Continue" button is imediately highlighted when the Node opens

func _on_continue_pressed() -> void:
	_start_game.emit()


func _on_new_game_pressed() -> void:
	_new_game.emit()


func _on_options_pressed() -> void:
	_open_options.emit()


func _on_exit_game_pressed() -> void:
	_exit_game.emit()
	
