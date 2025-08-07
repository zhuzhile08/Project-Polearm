extends Control

signal exitOptionsMenu

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_cancel"): # Exit options menu
		exitOptionsMenu.emit()
