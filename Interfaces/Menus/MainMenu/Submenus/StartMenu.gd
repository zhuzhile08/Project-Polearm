extends InterfaceState


#region Member variables

var _startGamePressed : bool = false
var _newGamePressed : bool = false
var _openOptionsPressed : bool = false
var _quitGamePressed : bool = false

#endregion


#region Implementation functions

func type() -> Type:
	return Type.startMenu

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel:
		pass
	
	if _openOptionsPressed:
		return Type.options
	
	return Type.none


func exit() -> int:
	if _startGamePressed:
		return MainMenuUberState.ExitType.startGame
	if _quitGamePressed:
		return MainMenuUberState.ExitType.quitGame

	return MainMenuUberState.ExitType.none

#endregion


#region Signal functions

func _on_continue_pressed() -> void:
	_startGamePressed = true

func _on_new_game_pressed() -> void:
	_newGamePressed = true

func _on_options_pressed() -> void:
	_openOptionsPressed = true

func _on_exit_game_pressed() -> void:
	_quitGamePressed = true

#endregion
