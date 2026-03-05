extends UberState
class_name GameUberState


#region Built-in functions

func _ready() -> void:
	var err := ResourceLoader.load_threaded_request(SCENE_PATH)

	assert(err == OK, "GameUberState._ready(): Request to load the scene resource failed!")

#endregion


#region Public functions

func finishedLoading() -> bool:
	match ResourceLoader.load_threaded_get_status(SCENE_PATH):
		ResourceLoader.THREAD_LOAD_LOADED:
			return true
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			return false
		_:
			assert(false, "GameUberState.finishedLoading(): Loading scene resource failed")
	
	return false

#endregion


#region Implementation functions

func type() -> Type:
	return Type.game

func createSceneImpl() -> Node:
	assert( \
		ResourceLoader.load_threaded_get_status(SCENE_PATH) == ResourceLoader.THREAD_LOAD_LOADED, \
		"GameUberState.createSceneImpl(): Scene resource has not finished loading! Please use the GameUberState.finishedLoading() function.")

	_sceneResource = ResourceLoader.load_threaded_get(SCENE_PATH)
	return _sceneResource.instantiate()

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass


func nextState() -> Type:
	return Type.none

#endregion
