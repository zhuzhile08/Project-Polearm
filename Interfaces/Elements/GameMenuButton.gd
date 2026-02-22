extends Button
class_name GameMenuButton

func _ready() -> void:
	mouse_entered.connect(mouseEntered)

func mouseEntered() -> void:
	# If the mouse touches the button, grabs focus
	if not has_focus():
		grab_focus()
