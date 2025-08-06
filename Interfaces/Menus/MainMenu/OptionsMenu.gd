extends Control

func _process(delta: float) -> void:
	if Input.is_action_pressed("Menu"):
		$".".hide()
		$"../StartMenu".show()
