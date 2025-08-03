extends PlayerAction

@export var WALK_SPEED : float = 0


func updateImpl(input : PlayerInputPackage, delta : float) -> void:
	actor.velocity = Vector3(input.direction.x, 0, input.direction.y) * WALK_SPEED * delta
	
	actor.move_and_slide()

func enterImpl() -> void:
	actor.velocity = Vector3.ZERO

func exitImpl() -> void:
	pass
