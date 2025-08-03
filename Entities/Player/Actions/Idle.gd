extends PlayerAction

func updateImpl(input : PlayerInputPackage, delta : float) -> void:
	pass

func enterImpl() -> void:
	actor.velocity = Vector3.ZERO

func exitImpl() -> void:
	pass
