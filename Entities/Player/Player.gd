# The architectual decisions and structure are heavily guided by https://github.com/Gab-ani/Godot_Universal-Controller-tutorial/tree/episode-5-overview-and-cleanup
# and it's accompanying YouTube tutorial series. Implementation details are heavily customized


extends CharacterBody3D
class_name Player


#region Enums

enum ActionType {
	none,
	

	# Idle
	idle,
	

	# Ground movement actions
	walk,
	run,
	sprint,
	

	# Jumping
	jumpBasic,
	jumpStill, jumpRun, jumpSprint,

	fall,

	# The landing animation can always determined, hence it needs no intermediate action
	landingStill, landingRun,
	

	# Dodge states
	dodgeBasic,
	dodgeGround, dodgeAir,


	# Hit states
	hitBasic,
	hitGround, hitAir, downedGround, downedAir, downedLanding,

	# u ded lmao skill issue
	death,


	# Combat can cancel out movement, but not eachother, but may be queried
	lightAttackBasic,
	heavyAttackBasic,
	
	# The sidearm type cannot be determined during polling time
	sidearm,
	ranged,
	whip,
	
	earthQuake,
	piercingShot,
	sonOfHeaven,

	# Taunts
	tauntBasic,
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
@onready var collider := $Collider as CollisionShape3D

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
