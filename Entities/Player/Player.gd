extends CharacterBody3D
class_name Player

# Helper structures

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


# Member variables

@onready var profile := PlayerProfile.new()

@onready var inputManager := $InputManager as PlayerInputManager
@onready var model := $Model as PlayerModel


# Member functions

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	var inputs : PlayerInputManager.Data = inputManager.pollInputs()
	model.update(inputs, delta)
