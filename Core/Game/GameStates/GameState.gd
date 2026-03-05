extends Node
class_name GameState


#region Exported variables

@export_file_path("*tscn", "*scn") var SCENE_PATH : String

#endregion


#region Enums

enum Type { 
	none,
	
	loading,
	playing,
	paused,
}

#endregion

#region Member variables

var _sceneResource : PackedScene = null

var scene : Node = null

#endregion


#region Built-in functions

func _ready() -> void:
	_sceneResource = load(SCENE_PATH)

#endregion


#region Member functions

func enter() -> void:
	scene = createSceneImpl()
	add_child(scene)

	enterImpl()

func exit() -> void:
	exitImpl()

	remove_child(scene)
	scene.queue_free()
	scene = null

#endregion


#region Implementation functions

func type() -> Type:
	return Type.none

func createSceneImpl() -> Node:
	return _sceneResource.instantiate()

func enterImpl() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT

func exitImpl() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED

func nextState() -> Type:
	return Type.none

#endregion
