extends UberState
class_name MainMenuUberState


#region Enums

enum ExitType {
	none,
	startGame,
	quitGame,
}

#endregion


#region Implementation functions

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass


func nextState(input : MainInputManager.Data) -> Type:
	scene.manageStates(input)

	var exitType := scene.exitType() as int

	if exitType == ExitType.startGame:
		return Type.game
	elif exitType == ExitType.quitGame:
		return Type.quit
	return Type.none

#endregion
