extends CanvasLayer
class_name InterfaceStateMachine


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
	
	initImpl()
	_currentMenu.enter()

#endregion


#region Public functions

func manageStates(input : MainInputManager.Data) -> void:
	var nextMenu : InterfaceState.Type = _currentMenu.nextMenu(input)
	if nextMenu != InterfaceState.Type.none:
		_switchTo(nextMenu)

func exitType() -> int:
	return 0

#endregion


#region Private functions

func _switchTo(nextState):
	_currentMenu.exit()
	_currentMenu = menus[nextState]
	_currentMenu.enter()

#endregion


#region Implementation functions

func initImpl() -> void:
	pass

#endregion
