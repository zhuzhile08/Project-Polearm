extends PlayerAction


func tickImpl(_input : PlayerInputManager.Data, _delta : float) -> void:
	pass

func enterImpl() -> void:
	player.velocity = Vector3.ZERO

func exitImpl() -> void:
	pass
