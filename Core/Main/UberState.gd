extends Node
class_name UberState


#region Enums

enum Type {
	none,

	boot,
	quit,
	mainMenu,
	game,
}

#endregion


#region Member variables

@export_file_path("*tscn", "*scn") var SCENE_PATH : String

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


# Called after entering the scene tree
func enterImpl() -> void:
	pass

# Called before exiting the scene tree
func exitImpl() -> void:
	pass


func nextState() -> Type:
	return Type.none

#endregion
