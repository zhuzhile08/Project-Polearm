extends Node
class_name Main


#region Member variables

var uberStates : Dictionary[UberState.Type, UberState]

var _currentState : UberState

#endregion


#region Build-in functions

func _ready() -> void:
	for child in get_children():
		if child is UberState:
			child.set_physics_process(false)
			uberStates[child.TYPE] = child
	
	_currentState = uberStates[UberState.Type.boot]
	_currentState.enter()

func _process(_delta : float) -> void:
	var nextState := _currentState.nextState()
	if nextState != UberState.Type.none:
		_switchTo(nextState)

#endregion


#region Private functions

func _switchTo(nextState):
	_currentState.exit()
	_currentState = uberStates[nextState]
	_currentState.enter()

#endregion
