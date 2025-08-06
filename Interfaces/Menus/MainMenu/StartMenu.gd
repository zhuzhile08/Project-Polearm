extends Control


# MainMenu Buttons
func playButtonPressed() -> void:
	print("pass")
	
func optionsButtonPressed() -> void:
	$".".hide()
	$"../OptionsMenu".show()
func exitGameButtonPressed() -> void:
	get_tree().quit()

# PlayMenu Buttons

# OptionsMenu Buttons
