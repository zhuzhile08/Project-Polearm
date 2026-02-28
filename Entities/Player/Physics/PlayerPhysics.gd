extends Node3D
# Referred to internally as Player Physics Processor
class_name PlayerPhysics


#region Helper classes

class LedgeData:
	var frontNormal : Vector3
	var grabPointLeft : Vector3
	var grabPointRight : Vector3
	var topFree : bool

#endregion


#region Constants



#endregion


#region Scene members



#endregion


#region Exported variables

@export_group("Ledge settings")
@export var MAX_LEDGE_DISTANCE : float = 0.4
@export var MAX_LEDGE_HEIGHT : float = 2.4
@export var MIN_LEDGE_HEIGHT : float = 1.4

@export_group("Jump settings")
@export var JUMP_BUFFER : float

#endregion


#region Member variables



#endregion


#region Built-in funcitons

func _ready() -> void:
	#assert(_model != null, "PlayerPhysics._ready(): Player model not assigned!")
	pass


func _physics_process(delta : float) -> void:
	pass


func _process(_delta : float) -> void:
	pass#DEBUG_drawCollisionPoints()


#endregion


#region Public funcitons



#endregion


#region Private functions



#endregion
