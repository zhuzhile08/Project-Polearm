extends GameState


#region Build-in functions

func _ready() -> void:
	var _gameScene = load(SCENE_PATH)
	add_child(_gameScene.instantiate())

#endregion


#region Implementation functions

func type() -> Type:
	return Type.playing

#endregion
