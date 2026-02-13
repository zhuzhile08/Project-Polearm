extends CharacterBody3D
class_name PlayerActor


#region Scene Members

@onready var inputManager := $InputManager as PlayerInputManager
@onready var model := $Model as PlayerModel

@export_category("Scene members")
@export var cameraManager : PlayerCameraManager

#endregion


#region Member variables

@onready var profile := PlayerProfile.new()

#endregion


#region Built-in functions

func _ready() -> void:
	assert(cameraManager != null, "PlayerActor._ready(): Camera manager not assigned!")

func _physics_process(delta: float) -> void:
	inputManager.pollInputs(cameraManager.cameraPlaneDirection())
	model.tick(inputManager.inputs, delta)

#endregion
