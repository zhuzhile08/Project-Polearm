extends GameState
class_name LoadingGameState


@export var _gameInstance : PlayingGameState = null


#region Build-in functions

func _ready() -> void:
	assert(_gameInstance != null, "LoadingScreen._ready(): Main menu wasn't assigned!")

	super._ready()

#endregion


#region Implementation functions
func type() -> Type:
	return Type.loading

func nextState() -> Type:
	if not scene.readyToSwitch():
		print("ha")
		return Type.none
	if not _gameInstance.finishedLoading():
		print("he")
		return Type.none
	print("ho")
	return Type.playing

#endregion
