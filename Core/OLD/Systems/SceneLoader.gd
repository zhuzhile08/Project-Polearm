extends Node


var worldContainer: Node = null# This is the Node where the 3D Scenes are loaded into

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func registerWorldContainer(container: Node) -> void:
	assert(container != null, "SceneLoader: Attempted to register a null worldContainer!")
	worldContainer = container
	print("SceneLoader: worldContainer registered successfully by ", container.name)
	
func loadLevel(path: String) -> bool:
	
	# Safety Check: Makes sure there is a place to put the level
	if worldContainer == null:
		push_error("Critical Error: SceneLoader doesn't have a world_container reference!")
		return false
	
	# Safety Check: Makes sure the path is valide
	if not ResourceLoader.exists(path):
		push_error("SceneLoader Error: File path does not exist: " + path)
		return false
	
	var sceneResource = ResourceLoader.load(path)
	
	if not sceneResource is PackedScene:
		push_error("SceneLoader Error: Resource at path is not a Scene: " + path)
		return false
	
	# 2. Clean up
	for child in worldContainer.get_children():
		child.queue_free()

	# 3. Load & Instantiate: The "Birth" of the new level
	var levelInstance = sceneResource.instantiate()
	worldContainer.add_child(levelInstance)
	
	print("SceneLoader: Successfully loaded " + path)
	return true
