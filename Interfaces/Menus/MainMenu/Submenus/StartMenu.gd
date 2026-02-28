extends InterfaceState


var _startGamePressed : bool = false
var _newGamePressed : bool = false
var _openOptionsPressed : bool = false
var _quitGamePressed : bool = false


func _on_continue_pressed() -> void:
	_startGamePressed = true

func _on_new_game_pressed() -> void:
	_newGamePressed = true

func _on_options_pressed() -> void:
	_openOptionsPressed = true

func _on_exit_game_pressed() -> void:
	_quitGamePressed = true


func nextMenu(inputs : MainInputManager.Data) -> Type:
	if inputs.cancel:
		pass
	
	if _openOptionsPressed:
		return Type.options
	
	return Type.none

func exitType() -> int:
	if _startGamePressed:
		return MainMenuUberState.ExitType.startGame
	if _quitGamePressed:
		return MainMenuUberState.ExitType.quitGame

	return MainMenuUberState.ExitType.none

