extends PlayerAction

@export var RUN_SPEED : float = 0

func updateImpl(input : PlayerInputManager.Data, delta : float) -> void:
	actor.velocity = Vector3(input.direction.x, 0, input.direction.y) * RUN_SPEED * delta
	
	actor.move_and_slide()

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass
