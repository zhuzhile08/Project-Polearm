extends Node3D
class_name PlayerCameraManager


#region Exported variables

@export var MIN_ANGLE : float
@export var MAX_ANGLE : float

#endregion


#region Scene members

# @onready var springArm := $SpringArm as SpringArm3D

var playerTarget : Player
var secondaryTarget : CharacterBody3D

#endregion


#region Member variables

var targetTransform : Transform3D

#endregion


#region Built-in functions

func _physics_process(delta: float) -> void:
	
	pass

#endregion


#region Member functions

func init(player : Player) -> void:
	playerTarget = player


func setLockOnTarget(target : CharacterBody3D = null) -> void:
	pass

func clearLockOnTarget() -> void:
	pass

#endregion
