extends CanvasLayer
class_name InterfaceStateMachine


#region Exported variables

@export var INITIAL_MENU_TYPE : InterfaceState.Type

#endregion


#region Scene members

@onready var inputManager := $InputManager as ISMInputManager

#endregion


#region Member variables

var menus : Dictionary[InterfaceState.Type, InterfaceState]

var _currentMenu : InterfaceState

#endregion


#region Build-in functions

func _ready() -> void:
	for child in get_children():
		if child is InterfaceState:
			child.hide()
			menus[child.type()] = child
	
	_currentMenu = menus[INITIAL_MENU_TYPE]
	_currentMenu.activate()

func _process(_delta : float) -> void:
	inputManager.pollInputs()

	var nextMenu := _currentMenu.nextMenu(inputManager.inputs)
	if nextMenu != InterfaceState.Type.none:
		_switchTo(nextMenu)

#endregion


#region Public functions

func exit() -> int:
	return _currentMenu.exit()

#endregion


#region Private functions

func _switchTo(nextState):
	_currentMenu.deactivate()
	_currentMenu = menus[nextState]
	_currentMenu.activate()

#endregion
