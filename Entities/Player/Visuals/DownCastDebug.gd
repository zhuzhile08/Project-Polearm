extends RayCast3D


@onready var collisionPoint := $CollisionPoint as CSGSphere3D


func _process(_delta: float) -> void:
	if is_colliding():
		collisionPoint.position = get_collision_point()
