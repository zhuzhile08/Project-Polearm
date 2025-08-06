extends Control

func _process(delta: float) -> void:
	
	# Return
	if Input.is_action_pressed("Menu"):
		$".".hide()
		$"../StartMenu".show()
