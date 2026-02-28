extends Control
class_name InterfaceState


#region Enums

enum Type { 
	none,
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


#region Exported variables

@export var TYPE : Type

#endregion


#region Member functions

func showMenu() -> void:
	show()

func hideMenu() -> void:
	hide()
	
#endregion


#region Implementation functions

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	return Type.none

func exit() -> int:
	return 0

#endregion
