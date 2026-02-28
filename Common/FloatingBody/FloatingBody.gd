# The logic behind the structure derive loosely from the methods used in https://github.com/NoiRC256/SRMove/
# A forward probing function to apply smoothing on slopes is directly inspired by the library

extends CharacterBody3D
class_name FloatingBody


#region Helper classes

class GroundData extends RefCounted:
	var point : Vector3 = Vector3.ZERO
	var normal : Vector3 = Vector3.ZERO

	var offset : float = 0

	var grounded : bool = false

	func clear() -> void:
		point = Vector3.ZERO
		normal = Vector3.ZERO
		offset = 0
		grounded = false
	
	func copy(other : GroundData) -> void:
		point = other.point
		normal = other.normal
		offset = other.offset
		grounded = other.grounded

#endregion


#region Enums

enum StepState {
	none,
	up,
	down,
}

#endregion


#region Constants

# Generall physics and collision settings

const MAX_GROUND_COLLISIONS : int = 4
const COLLISION_EPSILON : float = 0.001
const GROUND_DISTANCE_BUFFER = 1.01
const MIN_STEP_SPEED : float = 0.15 # Rigidbody collision resolution wants to move up on ledges


# Raycast settings

const STEP_RAY_SCALE_FACTOR : int = 4
const DOWNWARDS_RAY_LENGTH := Vector3(0.0, 10.0, 0.0)


# Hitbox configuration settings

const GROUND_CAST_DIST_TO_GROUND : float = 1
const STEP_RAY_VERTICAL_OFFSET : float = 0.03

#endregion


#region Exported variables

@export_group("Physics settings")
@export var BODY_COLLIDER_RADIUS = 0.5
@export var BODY_COLLIDER_FLOATING_HEIGHT : float = 0.3
@export var GROUND_CAST_RADIUS : float = 0.4

@export_group("Slope settings")
@export_range(-360, 360, 0.001, "radians_as_degrees") var SLOPE_MAX_ANGLE : float = 0.786

@export_group("Step settings")
@export var STEP_MAX_HEIGHT : float = 0.4
@export var STEP_SPEED_FACTOR : float = 0.4

#endregion


#region Scene members

@export_group("Scene Members")
@export var bodyCollider : CollisionShape3D
@export var groundCast : ShapeCast3D

#endregion


#region Member variables

# References

@onready var SLOPE_MAX_ANGLE_COS := cos(SLOPE_MAX_ANGLE)
@onready var COLLISION_LAYERS := groundCast.collision_mask

@onready var _bodyColliderShape := bodyCollider.shape as CapsuleShape3D
@onready var _groundCastShape := groundCast.shape as SphereShape3D


# State

var _groundData : GroundData = GroundData.new()
var _probeData : GroundData = GroundData.new()

var _stepState : StepState = StepState.none

var _grounded : bool = false

var _targetVelocity : Vector3


# Caching

@onready var _rayQuery : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO, COLLISION_LAYERS)

#endregion


#region Public functions

func init() -> void:
	_configureHitboxes()

func tick(delta : float) -> void:
	_processCollisions()
	_moveAndSmooth(delta)

	_groundData.clear()
	_probeData.clear()


# Movement functions

func move(vel : Vector3) -> void:
	_targetVelocity = vel


func snapToFloor() -> void:
	position.y -= _groundData.offset


# State functions

func onGround() -> bool:
	return _grounded

func onlyOnGround() -> bool:
	return onGround() and not is_on_ceiling() and not is_on_wall()

func onCeiling() -> bool:
	return is_on_ceiling()

func onlyOnCeiling() -> bool:
	return is_on_ceiling() and not onGround() and not is_on_wall()

func onWall() -> bool:
	return is_on_wall()

func onlyOnWall() -> bool:
	return is_on_wall() and not is_on_ceiling() and not onGround()


# Ground functions

func groundPoint() -> Vector3:
	return _groundData.point

func groundNormal() -> Vector3:
	return _groundData.normal

func forceGroundDataUpdate() -> void:
	if _stepState == StepState.down:
		_processFootCollisionData(_groundData)
	else:
		groundCast.force_shapecast_update()
		_processGroundCollisionData(_groundData)


#endregion


#region Private functions

# Initialization functions

func _configureHitboxes() -> void:
	groundCast.max_results = MAX_GROUND_COLLISIONS

	bodyCollider.position.y += BODY_COLLIDER_FLOATING_HEIGHT / 2
	_bodyColliderShape.height -= BODY_COLLIDER_FLOATING_HEIGHT

	_groundCastShape.radius = GROUND_CAST_RADIUS


# Physics functions

func _processCollisions() -> void:
	if _stepState == StepState.down:
		_processFootCollisionData(_groundData)
	else:
		_processGroundCollisionData(_groundData)

	# First order of business, we check for groundedness

	if not _groundData.grounded:
		_stepState = StepState.none
		_grounded = false

		return

	_grounded = true


	# We don't need to check further stuff if we are not moving anyways
	if _targetVelocity.length_squared() == 0:
		return


	# Stepping collision checks

    # We are checking for downwards steps first because stopping after stepping down and moving again may confuse
    # the system into thinking that we are stepping up before quickly stepping down again if we check step up first

	var direction := Vector3(_targetVelocity.x, 0, _targetVelocity.z).normalized()

	if _stepState != StepState.down:
		if _tryStepDown(direction):
			return
		elif _tryStepUp(direction):
			return
	elif _stepState != StepState.up and _tryStepUpFromProbe(direction):
		return
	else:
		_processFootCollisionData(_probeData)

	# If we are not stepping at all, we calculate a point in the direction the player is moving 
	# slightly behind the edge of the player hitbox. This allows us to perform a bit of smoothing

	_probePointInDirection(_probeData, global_position, _targetVelocity.normalized(), GROUND_CAST_RADIUS, 3)


func _moveAndSmooth(delta : float) -> void:
	if not onGround(): # Flying ignores all below calculations
		velocity = _targetVelocity
		move_and_slide()

		return

	if _stepState == StepState.none:
		if absf(_groundData.offset) < COLLISION_EPSILON:
			position.y -= _groundData.offset
			_groundData.offset = 0.0

		# If we are not stepping, we will preform a bit of movement smoothing Instead of rotating our velocity based on one
		# point, we rotate it based on the "average plane" between our probe point and ground point and overcorrect a bit

		# We overcorrect the line when the difference between ground and actual position is too big

		var line := Vector3(global_position.x, global_position.y + _groundData.offset, global_position.z) - _probeData.point

		# If the horizontal OR vertical component of line is too small
		if absf(line.y) < COLLISION_EPSILON or (line.x * line.x + line.z * line.z) < COLLISION_EPSILON * COLLISION_EPSILON:
			velocity = Utility.Math.rotateVectorOntoPlane(_targetVelocity, _groundData.normal)
		else:
			# The two cross products produce the final slope vector to rotate velocity by
			velocity = Utility.Math.rotateVectorOntoPlane(_targetVelocity, line.cross(_probeData.normal).cross(line).normalized())
	else:
		# If we know we are stepping, we will rotate the input velocity vector onto the plane of only the step point
		# We will also not apply any ground snapping, as this will ruin the stepping and since it already handles it sort of

		velocity = Utility.Math.rotateVectorOntoPlane(_targetVelocity, _groundData.normal)

		# Stepping logic, this already applies a small amount of snapping on the slope
		var offsetAbs := absf(_groundData.offset)
		if offsetAbs > COLLISION_EPSILON:
			velocity.y -= maxf(offsetAbs / delta * STEP_SPEED_FACTOR, MIN_STEP_SPEED) * signf(_groundData.offset)
		else:
			position.y -= _groundData.offset # Modify position directly for better snapping
			_stepState = StepState.none


	move_and_slide()


# Collision analysis functions

func _processGroundCollisionData(result : GroundData) -> void:
	if not groundCast.is_colliding():
		return

	result.point = _highestGroundPointGlobal()
	result.offset = _vertOffsetToPlayerGlobal(result.point)

	_initRayQuery(result.point + Vector3.UP, result.point - DOWNWARDS_RAY_LENGTH)
	result.normal = get_world_3d().direct_space_state.intersect_ray(_rayQuery).normal as Vector3

	if result.offset <= _bufferedGroundMaxDistance() and result.normal.y > SLOPE_MAX_ANGLE_COS:
		# As the normal vector is normalized, its angle can be determined by simply checking for its height
		result.grounded = true

func _processFootCollisionData(result : GroundData) -> void:
	_initRayQuery(global_position + Vector3.UP, global_position - DOWNWARDS_RAY_LENGTH)
	var collision := get_world_3d().direct_space_state.intersect_ray(_rayQuery)

	if not collision:
		return

	result.point = collision.position
	result.offset = _vertOffsetToPlayerGlobal(result.point)
	result.normal = collision.normal

	if result.offset <= _bufferedGroundMaxDistance() and result.normal.y > SLOPE_MAX_ANGLE_COS:
		# As the normal vector is normalized, its angle can be determined by simply checking for its height
		result.grounded = true

# Returns the farthest point on the line from startingPos towards direction * distance, which is continuously grounded
func _probePointInDirection(result : GroundData, startingPos : Vector3, direction : Vector3, distance : float, iterations : int) -> void:
	var iterDistance := distance / iterations
	var iterShift := direction * iterDistance
	iterShift.y = 0

	var pos := startingPos + iterShift

	for i : int in range(iterations):
		var posOffset := Vector3(0, STEP_MAX_HEIGHT - STEP_RAY_VERTICAL_OFFSET, 0) # We make our ray slightly lower than the max step height to prevent stepping to high)

		_initRayQuery(pos + posOffset, pos - DOWNWARDS_RAY_LENGTH)
		var collision := get_world_3d().direct_space_state.intersect_ray(_rayQuery)

		if not collision:
			break
		
		var point : Vector3 = collision.position
		var dist := _vertOffsetToPlayerGlobal(point)
		var normal : Vector3 = collision.normal

		if dist > _bufferedGroundMaxDistance() or normal.y <= SLOPE_MAX_ANGLE_COS:
			break

		result.point = point
		result.offset = dist
		result.normal = normal
		result.grounded = true
		
		pos += iterShift
		pos.y = point.y


# Step wall validation functions

# CAUTION: returns the non-globalized target position for usage in _validateStepProbeQueryDirection
func _calculateStepWallProbeQuery(sourcePointGlobal : Vector3, targetPointGlobal : Vector3) -> void:
	var sourcePos := Vector3(sourcePointGlobal.x, targetPointGlobal.y - STEP_RAY_VERTICAL_OFFSET, sourcePointGlobal.z)
	var targetPos := (targetPointGlobal - sourcePos) * STEP_RAY_SCALE_FACTOR
	targetPos.y = 0

	_initRayQuery(sourcePos, targetPos)

# We also check for a direction variable to prevent the body is moving in a direction incompatible with the step direction
func _validateStepProbeQueryDirection(direction : Vector3) -> bool:
	if _rayQuery.to.dot(direction) < 0:
		return false
	return true

# Checks if the wall of a step is actually a wall and not a slope
func _probeStepWall() -> bool:
	_rayQuery.to += _rayQuery.from
	var collision := get_world_3d().direct_space_state.intersect_ray(_rayQuery)
	
	if collision and (collision.normal as Vector3).y <= SLOPE_MAX_ANGLE_COS:
		return true
	
	return false


# Stepping functions

func _tryStepDown(direction : Vector3) -> bool:
	_processFootCollisionData(_probeData) # We will need the data from the probe if we are stepping
	_calculateStepWallProbeQuery(global_position, _groundData.point)

	if not _probeData.grounded:
		return false
	if _probeData.offset < STEP_RAY_VERTICAL_OFFSET:
		return false
	if not _validateStepProbeQueryDirection(-direction):
		return false

	if _probeStepWall(): # We don't need to check if the distance is too large for us to step down, as it was already done for _probeData.grounded
		_groundData.copy(_probeData) # We need to assign ground data to the probe data because the probe is the true "target position" of the player
		_stepState = StepState.down

	return true # Return true is placed here intentially, as we will not try to look for a step up if the wall probe fails anyways

func _tryStepUp(direction : Vector3) -> bool:
	if _stepState == StepState.up:
		return false
	if not _canStepUp(_groundData.offset, direction):
		return false

	_stepState = StepState.up
	return true

func _tryStepUpFromProbe(direction : Vector3) -> bool:
	_processGroundCollisionData(_probeData)
	_calculateStepWallProbeQuery(global_position, _probeData.point)

	if not _probeData.grounded:
		return false
	if not _canStepUp(_probeData.offset, direction):
		return false

	_groundData.copy(_probeData)
	_stepState = StepState.up

	return true

func _canStepUp(offset : float, direction : Vector3) -> bool:
	return (offset <= -STEP_RAY_VERTICAL_OFFSET and offset >= -STEP_MAX_HEIGHT and _validateStepProbeQueryDirection(direction) and _probeStepWall())


# Utility functions

# Returns a negative value if the point is above the player, and a positive one if the point is below the player
func _vertOffsetToPlayerGlobal(globalPos : Vector3) -> float:
	return global_position.y - globalPos.y

# Also saves the index of the current point
func _highestGroundPointGlobal() -> Vector3:
	assert(groundCast.is_colliding(), "PlayerPhysics._highestGlobalGroundPoint(): The player ground detection cast is not colliding. Always check collisions first!")

	var result := groundCast.get_collision_point(0)

	for i : int in range(1, groundCast.get_collision_count()):
		var curr := groundCast.get_collision_point(i)

		if curr.y > result.y:
			result = curr
	
	return result

# The maximum ground distance introduces some leniency, which changes whether the player is on the ground or not
func _bufferedGroundMaxDistance() -> float:                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
	if onGround():
		return (BODY_COLLIDER_FLOATING_HEIGHT + STEP_MAX_HEIGHT) * GROUND_DISTANCE_BUFFER
	return BODY_COLLIDER_FLOATING_HEIGHT * GROUND_DISTANCE_BUFFER

# Assign our cached ray cast query
func _initRayQuery(from : Vector3, to : Vector3) -> void:
	_rayQuery.from = from
	_rayQuery.to = to


# Debug functionality, put in tick() for debugging
func DEBUG_drawCollisionPoints() -> void:
	if groundCast.is_colliding():
		var points : PackedVector3Array
		for i in range(groundCast.get_collision_count()):
			var pt := groundCast.get_collision_point(i)

			points.push_back(pt)
			DebugDraw3D.draw_arrow(pt, pt + groundCast.get_collision_normal(i), Color.PINK, 0.05)

		DebugDraw3D.draw_points(points, DebugDraw3D.POINT_TYPE_SQUARE, 0.1, Color.CRIMSON)

	if _groundData.point != Vector3.ZERO:
		var points : PackedVector3Array
		points.push_back(_groundData.point)
		DebugDraw3D.draw_points(points, DebugDraw3D.POINT_TYPE_SQUARE, 0.1, Color.BLUE)
		DebugDraw3D.draw_arrow(_groundData.point, _groundData.point + _groundData.normal, Color.LIGHT_BLUE, 0.05)
	
	if _probeData.point != Vector3.ZERO:
		var points : PackedVector3Array
		points.push_back(_probeData.point)
		DebugDraw3D.draw_points(points, DebugDraw3D.POINT_TYPE_SQUARE, 0.1, Color.GREEN)
		DebugDraw3D.draw_arrow(_probeData.point, _probeData.point + _probeData.normal, Color.LIGHT_GREEN, 0.05)

#endregion
