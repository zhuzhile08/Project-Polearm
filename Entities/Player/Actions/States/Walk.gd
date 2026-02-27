extends PlayerAction


@export var WALK_SPEED : float = 0


func tickImpl(input : PlayerInputManager.Data, delta : float) -> void:
	player.move(Vector3(input.direction.x, 0, input.direction.y) * WALK_SPEED)

func enterImpl() -> void:
	player.move(Vector3.ZERO)

func exitImpl() -> void:
	pass
