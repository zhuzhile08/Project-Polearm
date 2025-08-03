extends Node
class_name PlayerInputManager

@export var WALK_LIMIT_SQUARED : float


func pollInputs() -> PlayerInputPackage:
	var inputs := PlayerInputPackage.new()
	inputs.actions.append(Player.ActionType.idle)
	
	inputs.direction = Input.get_vector("Move left", "Move right", "Move forwards", "Move backwards")
	
	if inputs.direction != Vector2.ZERO:
		if Input.is_action_pressed("Sprint"):
			inputs.actions.append(Player.ActionType.sprint)
		elif inputs.direction.length_squared() > WALK_LIMIT_SQUARED:
			inputs.actions.append(Player.ActionType.run)
		else:
			inputs.actions.append(Player.ActionType.walk)
		
		inputs.direction = inputs.direction.normalized()
	
	# Movement options

	if Input.is_action_pressed("Jump"): # The exact starting animation type can already be determined here
		inputs.actions.append(Player.ActionType.jump)
	
	if Input.is_action_pressed("Dodge"):
		inputs.actions.append(Player.ActionType.dodge)

	# Combat options

	return inputs
