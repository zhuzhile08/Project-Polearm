extends Node
class_name GameStateMachine


#region Exported variables

@export var INITIAL_GAME_TYPE : GameState.Type

#endregion


#region Member variables

var _states : Dictionary[GameState.Type, GameState] = { }

var _currentState : GameState = null

#endregion


#region Build-in functions

func _ready() -> void:
	for child in get_children():
		if child is GameState:
			_states[child.type()] = child

	_currentState = _states[INITIAL_GAME_TYPE]
	_currentState.enter()

func _process(_delta : float) -> void:
	var nextState := _currentState.nextState()
	if nextState != GameState.Type.none:
		_switchTo(nextState)

#endregion


#region Private functions

func _switchTo(nextState : GameState.Type):
	_currentState.exit()
	_currentState = _states[nextState]
	_currentState.enter()

#endregion
