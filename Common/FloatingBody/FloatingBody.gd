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
const STEP_RAY_SCALE_FACTOR : int = 4
const DOWNWARDS_RAY_LENGTH := Vector3(0.0, 10.0, 0.0)


# Hitbox configuration settings

const GROUND_CAST_DIST_TO_GROUND : float = 1
const STEP_RAY_VERTICAL_OFFSET : float = 0.01

#endregion



#region Exported variables

@export_category("Physics settings")
@export var BODY_COLLIDER_RADIUS = 0.5
@export var BODY_COLLIDER_FLOATING_HEIGHT : float = 0.3
@export var GROUND_CAST_RADIUS : float = 0.4

@export_category("Slope settings")
@export_range(-360, 360, 0.001, "radians_as_degrees") var SLOPE_MAX_ANGLE : float = 0.786
@export var SLOPE_SNAP_LENGTH : float = 0.3

@export_category("Step settings")
@export var STEP_MAX_HEIGHT : float = 0.4
@export var STEP_SPEED_FACTOR : float = 0.45

#endregion


#region Scene members

@export_category("Scene Members")
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

#endregion


#region Built-in funcitons

func _ready() -> void:
	_configureHitboxes()


func _physics_process(delta : float) -> void:
	_processCollisions()
	_moveAndSmooth(delta)


#func _process(_delta : float) -> void: # Used for debugging purposes only
#	DEBUG_drawCollisionPoints()

#endregion


#region Public functions

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
		_groundData = _processFootCollisionData()
	else:
		groundCast.force_shapecast_update()
		_groundData = _processGroundCollisionData()


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
	_groundData = _processFootCollisionData() if _stepState == StepState.down else _processGroundCollisionData()

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

	if _stepState == StepState.none:
		_probeData = _processFootCollisionData() # We will need the data from the probe if we are stepping
		var stepQuery := _calculateStepWallProbeQuery(global_position, _groundData.point)
		var direction := Vector3(_targetVelocity.x, 0, _targetVelocity.z).normalized()

		# We are checking for downwards steps first because stopping after stepping down and moving again may confuse
		# the system into thinking that we are stepping up before quickly stepping down again if we check step up first

		if _probeData.grounded == true and _probeData.offset > STEP_RAY_VERTICAL_OFFSET and _validateStepWallProbeQuery(stepQuery, -direction):
			# We don't need to check if the distance is too large for us to step down, as it was already done for _probeData.grounded
			if _probeStepWall(stepQuery):
				_groundData = _probeData # We need to assign ground data to the probe data because the probe is the true "target position" of the player
				_stepState = StepState.down
				
				return
		elif _groundData.offset < -STEP_RAY_VERTICAL_OFFSET and _groundData.offset >= -STEP_MAX_HEIGHT and _validateStepWallProbeQuery(stepQuery, direction) and _probeStepWall(stepQuery):
			_stepState = StepState.up
			
			return

	# If we are not stepping at all, we calculate a point in the direction the player is moving 
	# slightly behind the edge of the player hitbox. This allows us to perform a bit of smoothing

	_probeData = _probePointInDirection(_processFootCollisionData(), global_position, _targetVelocity.normalized(), GROUND_CAST_RADIUS, 3)


func _moveAndSmooth(delta : float) -> void:
	if not onGround(): # Flying ignores all below calculations
		velocity = _targetVelocity
		move_and_slide()

		return
	
	# print(_stepState)

	if _stepState == StepState.none:
		if abs(_groundData.offset) < COLLISION_EPSILON:
			position.y -= _groundData.offset
			_groundData.offset = 0.0

		# If we are not stepping, we will preform a bit of movement smoothing Instead of rotating our velocity based on one
		# point, we rotate it based on the "average plane" between our probe point and ground point and overcorrect a bit

		# We overcorrect the line when the difference between ground and actual position is too big

		var line := Vector3(global_position.x, global_position.y + _groundData.offset, global_position.z) - _probeData.point
		#line.y *= 1 + (line.dot(_probeData.normal) if _probeData.normal.y > global_position.y else -line.dot(_probeData.normal))

		# The two cross products produce the final slope vector to rotate velocity by
		velocity = Utility.Math.rotateVectorOntoPlane(_targetVelocity, line.cross(_probeData.normal).cross(line).normalized())
	else:
		# If we know we are stepping, we will rotate the input velocity vector onto the plane of only the step point
		# We will also not apply any ground snapping, as this will ruin the stepping and since it already handles it sort of

		velocity = Utility.Math.rotateVectorOntoPlane(_targetVelocity, _groundData.normal)

		# Stepping logic, this already applies a small amount of snapping on the slope
		if abs(_groundData.offset) > COLLISION_EPSILON:
			velocity.y -= _groundData.offset / delta * STEP_SPEED_FACTOR # Divide by delta allows us to move an actual amount every frame
		else:
			position.y -= _groundData.offset # Modify position directly for better snapping
			_stepState = StepState.none


	move_and_slide()


# Collision analysis functions

func _processGroundCollisionData() -> GroundData:
	var result : GroundData = GroundData.new()

	if not groundCast.is_colliding():
		return result

	result.point = _highestGroundPointGlobal()
	result.offset = _vertOffsetToPlayerGlobal(result.point)

	var query := PhysicsRayQueryParameters3D.create( \
		result.point + Vector3.UP, \
		result.point - DOWNWARDS_RAY_LENGTH, \
		COLLISION_LAYERS)
	result.normal = get_world_3d().direct_space_state.intersect_ray(query).normal as Vector3

	if result.offset <= _bufferedGroundMaxDistance() and result.normal.y > SLOPE_MAX_ANGLE_COS:
		# As the normal vector is normalized, its angle can be determined by simply checking for its height
		result.grounded = true

	return result

func _processFootCollisionData() -> GroundData:
	var result : GroundData = GroundData.new()

	var query := PhysicsRayQueryParameters3D.create( \
		global_position + Vector3.UP, \
		global_position - DOWNWARDS_RAY_LENGTH, \
		COLLISION_LAYERS)
	var collision := get_world_3d().direct_space_state.intersect_ray(query)

	if collision:
		result.point = collision.position
		result.offset = _vertOffsetToPlayerGlobal(result.point)
		result.normal = collision.normal

		if result.offset <= _bufferedGroundMaxDistance() and result.normal.y > SLOPE_MAX_ANGLE_COS:
			# As the normal vector is normalized, its angle can be determined by simply checking for its height
			result.grounded = true

	return result

# Returns the farthest point on the line from startingPos towards direction * distance, which is continuously grounded
func _probePointInDirection(baseData : GroundData, startingPos : Vector3, direction : Vector3, distance : float, iterations : int) -> GroundData:
	var result := GroundData.new()
	result.point = baseData.point
	result.normal = baseData.normal
	result.offset = baseData.offset
	result.grounded = baseData.grounded

	var iterDistance := distance / iterations
	var iterShift := direction * iterDistance
	iterShift.y = 0

	var pos := startingPos + iterShift

	for i : int in range(iterations):
		var query := PhysicsRayQueryParameters3D.create( \
			pos + Vector3.UP, \
			pos - DOWNWARDS_RAY_LENGTH, \
			COLLISION_LAYERS)
		var collision := get_world_3d().direct_space_state.intersect_ray(query)

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

	return result


# Step wall validation functions

# CAUTION: returns the non-globalized target position for usage in _validateStepWallProbeQuery
func _calculateStepWallProbeQuery(sourcePointGlobal : Vector3, targetPointGlobal : Vector3) -> PhysicsRayQueryParameters3D:
	var sourcePos := Vector3(sourcePointGlobal.x, targetPointGlobal.y - STEP_RAY_VERTICAL_OFFSET, sourcePointGlobal.z)
	var targetPos := (targetPointGlobal - sourcePos) * STEP_RAY_SCALE_FACTOR
	targetPos.y = 0

	return PhysicsRayQueryParameters3D.create( \
		sourcePos, \
		targetPos, \
		COLLISION_LAYERS)

func _validateStepWallProbeQuery(query : PhysicsRayQueryParameters3D, direction : Vector3) -> bool:
	if query.to.dot(direction) < 0:
		# We also check for a direction variable, as if the body is moving in a direction
		# incompatible with the step direction, we report this as false to prevent a step
		return false
	
	return true

# Checks if the wall of a step is actually a wall and not a slope
func _probeStepWall(query : PhysicsRayQueryParameters3D) -> bool:
	query.to += query.from
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	
	if collision and (collision.normal as Vector3).y <= SLOPE_MAX_ANGLE_COS:
		return true
	
	return false



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


# Debug functionality
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
