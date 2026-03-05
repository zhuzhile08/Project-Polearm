extends GameState
class_name LoadingGameState


@export var _game : PlayingGameState = null


#region Build-in functions

func _ready() -> void:
	assert(_game != null, "LoadingScreen._ready(): Main menu wasn't assigned!")

	super._ready()

#endregion


#region Implementation functions

func type() -> Type:
	return Type.loading

func nextState() -> Type:
	if not scene.readyToSwitch():
		return Type.none
	if not _game.finishedLoading():
		return Type.none

	return Type.playing

#endregion
