extends UberState
class_name BootUberState


#region Built-in functions

func _physics_process(delta : float) -> void:
	pass

#endregion


#region Implementation functions

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass


func nextState() -> Type:
	if not scene.readyToSwitch():
		return Type.none

	return Type.mainMenu

#endregion
