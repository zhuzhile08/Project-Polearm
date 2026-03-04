extends UberState
class_name GameUberState


#region Implementation functions

func type() -> Type:
	return Type.game

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass


func nextState() -> Type:
	return Type.none

#endregion
