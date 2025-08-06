extends Control

var pressToStart = false;

func _ready() -> void:
	for child in get_children():
		child.hide()
		$StartMenu.show()
