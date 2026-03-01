extends UberState


#region Built-in functions

# Overwrite for custom _sceneResource loading behavior
func _ready() -> void:
	pass

#endregion


#region Implementation functions

func type() -> Type:
	return Type.none


func createSceneImpl() -> Node:
	return _sceneResource.instantiate()

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass


func nextState() -> Type:
	return Type.none

#endregion
