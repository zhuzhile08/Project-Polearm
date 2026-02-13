extends PlayerAction


@export var WALK_SPEED : float = 0


func tickImpl(input : PlayerInputManager.Data, _delta : float) -> void:
	player.velocity = Vector3(input.direction.x, 0, input.direction.y) * WALK_SPEED
	
	player.move_and_slide()

func enterImpl() -> void:
	player.velocity = Vector3.ZERO

func exitImpl() -> void:
	pass
