extends Node
class_name GameStateMachine


#region Exported variables

@export var INITIAL_GAME_TYPE : GameState.Type

#endregion


#region Member variables

var _gameStates : Dictionary[GameState.Type, GameState]

var _currentgameState : GameState

#endregion


#region Build-in functions

func _ready() -> void:
	for child in get_children():
		if child is GameState:
			_gameStates[child.type()] = child
			child.exit()
	if _gameStates.has(INITIAL_GAME_TYPE):
		_currentgameState = _gameStates[INITIAL_GAME_TYPE]
		_currentgameState.enter()

func _process(delta: float) -> void:
	if not _currentgameState:
		return

func _switchTo(next_type: GameState.Type) -> void:
	if not _gameStates.has(next_type):
		return

	_currentgameState.exit()
	_currentgameState = _gameStates[next_type]
	_currentgameState.enter()


#endregion
