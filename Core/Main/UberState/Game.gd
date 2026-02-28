extends UberState


#region Built-in functions

func _physics_process(delta : float) -> void:
	pass

#endregion


#region Implementation functions

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass


func nextState(_input : MainInputManager.Data) -> Type:
	return Type.none

#endregion
