extends PlayerAction


@export var RUN_SPEED : float = 0


func tickImpl(input : PlayerInputManager.Data, delta : float) -> void:
	physics.velocity = Vector3(input.direction.x, 0, input.direction.y) * RUN_SPEED
	
	physics.moveAndSlide(delta)

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass
