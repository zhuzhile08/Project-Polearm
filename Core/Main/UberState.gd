extends Node
class_name UberState


#region Enums

enum Type {
	none,

	boot,
	mainMenu,
	game,
}

#endregion


#region Exported variables

@export var TYPE : Type
@export_file_path("*tscn", "*scn") var SCENE_PATH : String

#endregion


#region Scene memebers

var scene : Node

#endregion


#region Member variables

@onready var _sceneResource : PackedScene = load(SCENE_PATH)

#endregion


#region Member functions

func enter() -> void:
	set_physics_process(true)
	scene = _sceneResource.instantiate()
	add_child(scene)

	enterImpl()

func exit() -> void:
	set_physics_process(false)
	remove_child(scene)

	exitImpl()

func nextState(_input : MainInputManager.Data) -> Type:
	return Type.none

#endregion


#region Implementation functions

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass

#endregion
