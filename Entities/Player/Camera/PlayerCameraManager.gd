extends Node
class_name PlayerCameraManager


# Camera input data
class CameraInputData:
	var direction : Vector2
	var targetDirection : float # > 0 means targeting left, > 0 means targeting right
	var heldTargetToggle : bool # > 0 means target button must be held, > 0 means target button is a toggle


#region Exported variables

@export_category("Camera config")
@export var MIN_PITCH : float = -80
@export var MAX_PITCH : float = 30

@export_category("Controls")
@export var INVERT_VERTICAL : float = -1 # Set to 1 to invert y axis
@export var CONTROLLER_SENSITIVITY : float
@export var MOUSE_SENSITIVITY : float

#endregion


#region Scene members

@onready var followCam := $FollowCam as PhantomCamera3D

#endregion


#region Member variables

var activeCam : PhantomCamera3D

var heldTargetToggle : bool = false
var isTargeting : bool = false # Only active if the above toggle is true

#endregion


#region Built-in functions

func _physics_process(delta: float) -> void:
	var input := handleInput()

	rotateCamera(followCam, Vector2(input.direction.y * delta * CONTROLLER_SENSITIVITY, input.direction.x * delta * CONTROLLER_SENSITIVITY))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouseDelta = event.relative * MOUSE_SENSITIVITY
	
		rotateCamera(followCam, Vector2(-mouseDelta.y, mouseDelta.x))

#endregion


#region Public functions

func setFollowTarget(node : Node3D) -> void:
	followCam.set_follow_target(node)

	activeCam = followCam # TEMPORARY


# func setLockOnTarget(target : CharacterBody3D = null) -> void:
#	pass

# func clearLockOnTarget() -> void:
#	pass


func cameraPlaneDirection() -> Vector2:
	var direction = activeCam.global_position - activeCam._follow_target_output_position # Private variable of PhantomCamera3D, maybe someday open PR to add a proper getter function
	return Vector2(direction.x, direction.z).normalized()


#endregion


#region Private functions

func rotateCamera(camera : PhantomCamera3D, angle : Vector2) -> void:
	var cameraRotation := camera.get_third_person_rotation_degrees()

	cameraRotation.y = wrapf(cameraRotation.y - angle.y, 0, 360)
	cameraRotation.x = clampf(cameraRotation.x + angle.x * INVERT_VERTICAL, MIN_PITCH, MAX_PITCH)

	camera.set_third_person_rotation_degrees(cameraRotation)

func handleInput() -> CameraInputData:
	var data : CameraInputData = CameraInputData.new()

	# if not mouseCamera: # Mouse rotation is handled in _unhandled_input() # How to check?
	data.direction = Input.get_vector("Camera left", "Camera right", "Camera down", "Camera up").normalized()

	data.targetDirection = Input.get_axis("Target left", "Target right")
	data.heldTargetToggle = Input.is_action_pressed("Held target toggle")

	return data

#endregion
