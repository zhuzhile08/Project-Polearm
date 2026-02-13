extends CharacterBody3D
class_name Player


enum ActionType {
	none,
	
	# Special states
	death,
	hit,
	
	# Dodges can cancel everything
	dodge,
	
	# Combat can cancel out movement, but not eachother, but may be queried
	lightAttack,
	heavyAttack,
	
	# The sidearm type cannot be determined during polling time
	sidearm,
	ranged,
	whip,
	
	earthQuake,
	piercingShot,
	sonOfHeaven,

	taunt,
	
	# Primary movement actions
	jumpStart,
	sprint,
	run,
	walk,
	
	# Secondary movement actions
	jump,
	fall,
	landing,
	
	# Idle
	idle,
}

enum ComboType {
	none,
	unknown = none,
	
}

enum FlowState {
	none,
	mortal,
	cultivating,
	enlightened,
	sage,
	immortal,
	divine,
	heavenly,
}

#endregion


#region Scene Members

@onready var inputManager := $InputManager as PlayerInputManager
@onready var model := $Model as PlayerModel
@onready var cameraManager := $CameraManager as PlayerCameraManager
@onready var visuals := $XBotMesh as XBotMesh

#endregion


#region Member variables

@onready var profile := PlayerProfile.new()

#endregion


#region Built-in functions

func _ready() -> void:
	cameraManager.setFollowTarget(self)
	visuals.acceptSkeleton(model.skeleton)


func _physics_process(delta: float) -> void:
	inputManager.pollInputs(cameraManager.cameraPlaneDirection())
	model.tick(inputManager.inputs, delta)

#endregion
