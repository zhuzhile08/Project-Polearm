extends Node
class_name Player


#region Enums

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


#region Built-in functions

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#endregion
