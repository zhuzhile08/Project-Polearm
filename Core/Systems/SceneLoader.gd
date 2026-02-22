extends Node


var worldContainer: Node # This is the Node where the 3D Scenes are loaded into

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func loadLevel(path: String) -> void:
	# 1. Safety Check: Make sure we have a place to put the level
	if worldContainer == null:
		print("Critical Error: SceneLoader doesn't have a world_container reference!")
		return

	# 2. Clean up: Remove any level currently in the container
	for child in worldContainer.get_children():
		child.queue_free()

	# 3. Load & Instantiate: The "Birth" of the new level
	var scene_resource = load(path)
	if scene_resource:
		var level_instance = scene_resource.instantiate()
		
		# 4. Add to Tree: Put the level into the "Slot"
		worldContainer.add_child(level_instance)
		
	else:
		print("Error: Could not load level file at ", path)
