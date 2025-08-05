extends PlayerAction

func updateImpl(input : PlayerInputManager.Data, delta : float) -> void:
	pass

func enterImpl() -> void:
	actor.velocity = Vector3.ZERO

func exitImpl() -> void:
	pass
