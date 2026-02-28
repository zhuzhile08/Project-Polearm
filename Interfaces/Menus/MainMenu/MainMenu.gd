extends InterfaceStateMachine
class_name MainMenu


#region Enums

enum ExitType {
	none,
	game,
	quit,
}

#endregion


#region Public functions

func exitType() -> int:
	return 0

#endregion


#region Implementation functions

func initImpl() -> void:
	_currentMenu = menus[InterfaceState.Type.mainMenu]

#endregion
