extends UberState
class_name MainMenuUberState


#region Enums

enum ExitType {
	none,
	startGame,
	quitGame,
}

#endregion


#region Built-in functions

func _ready() -> void:
	var err := ResourceLoader.load_threaded_request(SCENE_PATH)

	assert(err == OK, "MainMenuUberState._ready(): Request to load the scene resource failed!")

#endregion


#region Implementation functions

func type() -> Type:
	return Type.mainMenu


func createSceneImpl() -> Node:
	while true:
		match ResourceLoader.load_threaded_get_status(SCENE_PATH):
			ResourceLoader.THREAD_LOAD_LOADED:
				_sceneResource = ResourceLoader.load_threaded_get(SCENE_PATH)
				return _sceneResource.instantiate()
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				pass
			_:
				assert(false, "MainMenuUberState.createSceneImpl(): Loading scene resource failed")
				return null

	return null

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass


func nextState() -> Type:
	match scene.exit() as int:
		ExitType.startGame:
			return Type.game
		ExitType.quitGame:
			return Type.quit

	return Type.none

#endregion
