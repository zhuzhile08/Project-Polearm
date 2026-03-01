extends UberState
class_name BootUberState


#region Implementation functions

func type() -> Type:
	return Type.boot

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	_sceneResource = null # Also delete the scene resource, as we only boot once


func nextState() -> Type:
	if not scene.readyToSwitch():
		return Type.none

	return Type.mainMenu

#endregion
