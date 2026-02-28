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

func enter() -> void:
	show()

func exit() -> void:
	hide()

func nextMenu(inputs : MainInputManager.Data) -> Type:
	return Type.none

func exitType() -> int:
	return 0

func showMenu() -> void:
	show()

func hideMenu() -> void:
	hide()
	
#endregion
