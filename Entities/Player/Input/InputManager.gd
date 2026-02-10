extends Node
class_name PlayerInputManager


# Input data container
class Data extends RefCounted:
	var direction : Vector2
	var actions : Array[Player.ActionType]
	
	func reset():
		direction = Vector2.ZERO
		actions.clear()


# Configurable variables

@export var WALK_LIMIT_SQUARED : float


# Member variables

var inputs : Data


# Member functions

func pollInputs():
	inputs.reset()
	inputs.actions.append(Player.ActionType.idle)
	
	processMovementDirection()
	processMovementActions()


# Internal functions

func processMovementDirection():
	inputs.direction = Input.get_vector("Move left", "Move right", "Move forwards", "Move backwards")
	
	if inputs.direction == Vector2.ZERO:
		return
		
	if Input.is_action_pressed("Sprint"):
		inputs.actions.append(Player.ActionType.sprint)
	elif inputs.direction.length_squared() > WALK_LIMIT_SQUARED:
		inputs.actions.append(Player.ActionType.run)
	else:
		inputs.actions.append(Player.ActionType.walk)
	
	inputs.direction = inputs.direction.normalized()

func processMovementActions():
	if Input.is_action_pressed("Jump"):
		inputs.actions.append(Player.ActionType.jump)
	
	if Input.is_action_pressed("Dodge"):
		inputs.actions.append(Player.ActionType.dodge)
