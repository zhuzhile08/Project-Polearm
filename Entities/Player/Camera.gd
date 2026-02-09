extends Node3D

# Configurable variables
@export var MIN_ANGLE : float
@export var MAX_ANGLE : float


# Mamber variables

@onready var springArm := $SpringArm as SpringArm3D

var playerTarget : Player
var secondaryTarget : CharacterBody3D

var targetTransform : Transform3D


# Member functions

func init(player : Player) -> void:
	playerTarget = player


func setLockOnTarget(target : CharacterBody3D = null) -> void:
	pass

func clearLockOnTarget() -> void:
	pass


func _physics_process(delta: float) -> void:
	
	pass
