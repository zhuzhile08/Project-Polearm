extends Node
class_name Main


#region Scene members

@onready var inputManager := $InputManager as MainInputManager

#endregion


#region Member variables

var uberstates : Dictionary[Uberstate.Type, Uberstate]

var _currentState : Uberstate

#endregion


#region Build-in functions

func _ready() -> void:
	for child in get_children():
		if child is Uberstate:
			uberstates[child.TYPE] = child

func _physics_process(delta : float) -> void:
	var inputData := inputManager.processInputs()
	
	var nextState : Uberstate.Type = _currentState.nextState(inputData)
	if nextState != Uberstate.Type.none:
		_transitionState(nextState)

#endregion




func _transitionState(nextState):
	_currentState.exit()
	_currentState = uberstates[nextState]
	_currentState.enter()
