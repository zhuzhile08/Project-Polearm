extends Button

func _ready() -> void:
	mouse_entered.connect(mouseEntered)
	pressed.connect(buttonPressed)

func mouseEntered() -> void:
	# If the mouse touches the button, grabs focus
	if not has_focus():
		grab_focus()

func buttonPressed() -> void:
	pass
