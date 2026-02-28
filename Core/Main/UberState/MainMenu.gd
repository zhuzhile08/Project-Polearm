extends UberState
class_name MainMenuUberState


#region Implementation functions

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass


func nextState(input : MainInputManager.Data) -> Type:
	scene.manageStates(input)

	var exitType := scene.exitType()

	if exitType == MainMenu.ExitType.game:
		return Type.game
	elif exitType == MainMenu.ExitType.quit:
		return Type.quit
	return Type.none

#endregion
