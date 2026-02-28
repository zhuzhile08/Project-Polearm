extends Node3D


@export var timer : float = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	timer -= delta

func readyToSwitch() -> bool:
	return timer < 0.0
