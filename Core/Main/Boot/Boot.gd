extends Node3D


@export var timer : float = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	timer -= delta

	if timer < 0.0:
		print("haha")

func readyToSwitch() -> bool:
	return timer < 0.0
