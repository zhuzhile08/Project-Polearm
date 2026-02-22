extends PlayerAction


@export var WALK_SPEED : float = 0


func tickImpl(input : PlayerInputManager.Data, delta : float) -> void:
	physics.velocity = Vector3(input.direction.x, 0, input.direction.y) * WALK_SPEED
	
	physics.moveAndSlide(delta)

func enterImpl() -> void:
	player.velocity = Vector3.ZERO

func exitImpl() -> void:
	pass
