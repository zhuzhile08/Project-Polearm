extends CanvasLayer
class_name InterfaceStateMachine


#region Exported variables

@export var INITIAL_MENU_TYPE : InterfaceState.Type

#endregion


#region Member variables

var menus : Dictionary[InterfaceState.Type, InterfaceState]

var _currentMenu : InterfaceState

#endregion


#region Build-in functions

func _ready() -> void:
	for child in get_children():
		if child is InterfaceState:
			child.hideMenu()
			menus[child.TYPE] = child
	
	_currentMenu = menus[INITIAL_MENU_TYPE]
	_currentMenu.enter()

#endregion


#region Public functions

func manageStates(input : MainInputManager.Data) -> void:
	var nextMenu : InterfaceState.Type = _currentMenu.nextMenu(input)
	if nextMenu != InterfaceState.Type.none:
		_switchTo(nextMenu)

func exitType() -> int:
	return _currentMenu.exitType()

#endregion


#region Private functions

func _switchTo(nextState):
	_currentMenu.exit()
	_currentMenu = menus[nextState]
	_currentMenu.enter()

#endregion
