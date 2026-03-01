extends Control
class_name InterfaceState


#region Enums

enum Type { 
	none,
	quitConfirmMenu,
	startMenu,
	options,
	pause,
	gameOptions,
	videoOptions,
	audioOptions,
	controllerOptions,
	keyboardOptions,
}

#endregion


#region Member variable

@onready var currentButton : Control = find_next_valid_focus()

#endregion


#region Member functions

func activate() -> void:
	show()
	
	if currentButton:
		currentButton.grab_focus()

func deactivate() -> void:
	hide()
	deactivateImpl()
	
#endregion


#region Implementation functions

func type() -> Type:
	return Type.none

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	return Type.none

func deactivateImpl() -> void:
	pass

func exit() -> int:
	return 0

#endregion
