extends Node
class_name GameStateMachine


#region Exported variables

@export var INITIAL_GAME_TYPE : GameState.Type

#endregion


#region Member variables

var _gameStates : Dictionary[GameState.Type, GameState] = { }

var _currentGameState : GameState = null

#endregion


#region Build-in functions

func _ready() -> void:
	for child in get_children():
		if child is GameState:
			_gameStates[child.type()] = child
	if _gameStates.has(INITIAL_GAME_TYPE):
		_currentGameState = _gameStates[INITIAL_GAME_TYPE]
		_currentGameState.enter()

func _process(_delta : float) -> void:
	var nextState := _currentGameState.nextState()
	if nextState != GameState.Type.none:
		_switchTo(nextState)

#endregion


#region Private functions

func _switchTo(nextState : GameState.Type):
	_currentGameState.exit()
	_currentGameState = _gameStates[nextState]
	_currentGameState.enter()

#endregion
