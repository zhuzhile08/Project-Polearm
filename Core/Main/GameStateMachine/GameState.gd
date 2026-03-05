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


#region Implementation functions

func type() -> Type:
	return Type.none

func enter() -> void:
	set_process(true)
	set_physics_process(true)

func exit() -> void:
	set_process(false)
	set_physics_process(false)

#endregion