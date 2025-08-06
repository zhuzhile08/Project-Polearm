extends Control

# StartMenu Buttons
func playButtonPressed() -> void:
	get_tree().change_scene_to_file("res://Stages/Main.tscn")
	
func optionsButtonPressed() -> void:
	$".".hide()
	$"../OptionsMenu".show()
	
func exitGameButtonPressed() -> void:
	get_tree().quit()

# PlayMenu Buttons

# OptionsMenu Buttons
