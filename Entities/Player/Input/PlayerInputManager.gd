extends Node
class_name PlayerInputManager


# Input data container
class Data extends RefCounted:
	var cameraDirection : Vector2
	var inputDirection : Vector2
	var direction : Vector2

	var actions : Array[Player.ActionType]
	
	func reset() -> void:
		actions.clear() # Both directions don't have to be reset because they will be reassigned every time


#region Exported variables

@export_category("Config")
@export var WALK_LIMIT_SQUARED : float

#endregion


#region Member variables

var inputs : Data = Data.new()

#endregion


#region Public functions

func pollInputs(cameraDirection : Vector2) -> void:
	inputs.reset()
	inputs.actions.append(Player.ActionType.idle)

	inputs.cameraDirection = cameraDirection
	processMovementDirection()
	
	processMovementActions()

#endregion


#region Private functions

func processMovementDirection() -> void:
	inputs.inputDirection = Input.get_vector("Move left", "Move right", "Move forwards", "Move backwards")
	
	if inputs.inputDirection == Vector2.ZERO:
		return
		
	if Input.is_action_pressed("Sprint"):
		inputs.actions.append(Player.ActionType.sprint)
	elif inputs.inputDirection.length_squared() > WALK_LIMIT_SQUARED:
		inputs.actions.append(Player.ActionType.run)
	else:
		inputs.actions.append(Player.ActionType.walk)
	
	inputs.inputDirection = inputs.inputDirection.normalized()

	# The code below is a transformation of the input direction by the angle the camera is currently pointing in
	#
	# First, to rotate the vector, we need the right instead of the forward vector of the camera. Hence, we rotate
	# the camera by -90 degrees. This is given by the transformation [0 1, -1 0] * [x_c y_c] = [y_c -x_c]
	#
	# As the camera direction has already been normalized, the final rotation matrix is given by [-y_c -x_c, x_c -y_c]
	# The transformation [y_c x_c, -x_c y_c] * [x y] = [(y_c * x + x_c * y) (-x_c * x + y_c * y)]
	# This can be rearranged as y_c * [x y] + x_c * [y -x]

	inputs.direction = Vector2( \
		inputs.inputDirection * inputs.cameraDirection.y \
		 + Vector2(inputs.inputDirection.y, -inputs.inputDirection.x) * inputs.cameraDirection.x \
	).normalized()

func processMovementActions():
	if Input.is_action_pressed("Jump"):
		inputs.actions.append(Player.ActionType.jump)
	
	if Input.is_action_pressed("Dodge"):
		inputs.actions.append(Player.ActionType.dodge)

#endregion
