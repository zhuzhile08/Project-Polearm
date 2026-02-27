extends Node3D
# Referred to internally as Player Physics Processor
class_name PlayerPhysics


var comment = """
#region Helper classes

class LedgeData:
	var frontNormal : Vector3
	var grabPointLeft : Vector3
	var grabPointRight : Vector3
	var topFree : bool

#endregion


#region Constants

# Generall physics and collision settings

const MAX_COLLISIONS : int = 4
const COLLISION_EPSILON : float = 0.001


# Hitbox configuration settings

const GROUND_CAST_DIST_TO_GROUND : float = 1
const STEP_RAY_VERTICAL_OFFSET : float = 0.01
const STEP_RAY_VERTICAL_OFFSET_EP : float = STEP_RAY_VERTICAL_OFFSET - COLLISION_EPSILON
const PASSIVE_GRAVITY_VALUE = 3
const ATTACHED_TO_GROUND_BUFFER = 0.1

#endregion


#region Exported variables

@export_category("Physics settings")
@export var GROUND_CAST_RADIUS_DIFFERENCE : float = 0.2

@export_category("Slope settings")
@export_range(-360, 360, 0.001, "radians_as_degrees") var MAX_SLOPE_ANGLE : float = 0.786
@export var SLOPE_SNAP_LENGTH : float = 0.3

@export_category("Step settings")
@export var MAX_STEP_HEIGHT : float = 0.5
@export var MIN_STEP_LENGTH : float = 0.2
@export var STEP_UP_SPEED : float = 15
@export var STEP_DOWN_SPEED : float = 25

@export_category("Ledge settings")
@export var MAX_LEDGE_DISTANCE : float = 0.4
@export var MAX_LEDGE_HEIGHT : float = 2.4
@export var MIN_LEDGE_HEIGHT : float = 1.4

@export_category("Jump settings")
@export var JUMP_BUFFER : float

#endregion


#region Member variables

# Player collision references

var _bodyCollider : CollisionShape3D
var _bodyColliderShape : CapsuleShape3D

var _footCollider : CollisionShape3D
var _footColliderShape : CapsuleShape3D


# Physics processor references

var _groundCastShape : SphereShape3D


# Proper variables

var _stepUp : bool = false
var _stepDown : bool = false

var _grounded : bool = false
var _trueGrounded : bool = false
var _lastDistToGround : float = 0

var _currentGroundPointIndex : int = 0


# Physics

var velocity : Vector3

var _attachToGround : bool = true


#endregion


#region Built-in funcitons

func _ready() -> void:
	assert(_model != null, "PlayerPhysics._ready(): Player model not assigned!")


func _physics_process(delta : float) -> void:
	#if not groundCast.is_colliding():
	#	_trueGrounded = false
	#	return

	#var groundPoint := _highestGroundPointGlobal()
	#var distToPlayer := _vertDistToPlayer(groundPoint)

	#if _stepUp: # Step up smoothing
	#	if distToPlayer < -COLLISION_EPSILON and distToPlayer >= -MAX_STEP_HEIGHT - COLLISION_EPSILON:
	#		_player.position.y += lerpf(0, -distToPlayer, minf(STEP_UP_SPEED * delta, 1.0))
	#	else:
	#		_stepUp = false
	#elif _stepDown: # Step down smoothing
	#	_aimDownCast(_player.global_position)
	#	var stepDownDist := _vertDistToPlayer(downCast.get_collision_point())

	#	if stepDownDist > COLLISION_EPSILON and stepDownDist <= MAX_STEP_HEIGHT + COLLISION_EPSILON:
	#		_player.position.y -= lerpf(0, stepDownDist, minf(STEP_DOWN_SPEED * delta, 1.0))
	#	else:
	#		_stepDown = false
	#else: # Attempt to keep the player on the ground
	#	if _attachToGround:
			# You can walk on the edge of a steep slope. This is to move the point in by a tiny amount so that the ray always hits
	#		_aimDownCast(groundPoint - groundCast.get_collision_normal(_groundPtIdx) * 0.01)
	#		var walkableGround = downCast.is_colliding() and downCast.get_collision_normal().angle_to(Vector3.UP) <= MAX_SLOPE_ANGLE

	#		if distToPlayer > 0: # We apply a tiny amount of passive gravity
	#			_player.position.y -= minf(0.05, distToPlayer)
	#		elif distToPlayer < 0 and walkableGround: # We push the player back upwards if they are clipped into the box
	#			_player.position.y += minf(0.1, -distToPlayer)

	#		_trueGrounded = walkableGround and distToPlayer < COLLISION_EPSILON
	#		_grounded = walkableGround and distToPlayer < ATTACHED_TO_GROUND_BUFFER
	#		_lastDistToGround = distToPlayer
	#	else:
	#		_trueGrounded = distToPlayer < COLLISION_EPSILON
	# print(_player.is_on_floor())
	pass


func _process(_delta : float) -> void:
	pass#DEBUG_drawCollisionPoints()


#endregion


#region Public funcitons

# Movement functions

func moveAndSlide(delta : float) -> void:
	_player.velocity = velocity
	_player.move_and_slide()

	#if not groundCast.is_colliding(): # Just move if the player is in the air
	#	_player.velocity = velocity
	#	_player.move_and_slide()
	#	return


	# Initial setup

	# groundCast.force_shapecast_update()
	var groundPoint := _highestGlobalGroundPoint()
	var distToPlayer := _vertDistToPlayer(groundPoint)

	var possibleStepUp : bool = _stepUp
	var possibleStepDown : bool = _stepDown

	var stepDownDist : float = 0


	# Initial step detection phase
	
	if _player.is_on_floor(): # Only check for potential steps when the player is not in the air
		# We check the floor directly under the player
		_aimDownCast(_player.global_position)
		var stepDownPoint := _downCast.get_collision_point()
		stepDownDist = _vertDistToPlayer(stepDownPoint)

		# If this check is true, we are definetly going down by an amount and therefore definetly going up
		if _downCast.is_colliding() and stepDownDist > STEP_RAY_VERTICAL_OFFSET_EP:
			if not _stepDown: # No need to do this check if we are already going down
				# We have also only verified that the current step is going down, but not if the lower point is steppable. We will wait
				# until the player is far out enough, as stepping logic only starts when the player is not on a sloped wall anymore.

				# Checking for the validity of the step wall, as we don't want to step down if we are on a slope.
				# Given that we have detected that we are going down, Pointing at the current groundPoint is not reliable, as if the step wall is perfectly vertical,
				# there is a large chance that we have overshot it.
				# This is a variant of the _aimStepCast algorithm

				_stepCast.global_position = Vector3(_player.global_position.x, \
													max(groundPoint.y - STEP_RAY_VERTICAL_OFFSET, stepDownPoint.y), \
													_player.global_position.z)
				_stepCast.target_position = stepCast.to_local(_player.global_position) * 8
				_stepCast.target_position.y = 0

				stepCast.force_raycast_update()

				# Confirm the collision point exists and is a step
				if stepCast.is_colliding() and stepCast.get_collision_normal().angle_to(Vector3(0, 1, 0)) > MAX_SLOPE_ANGLE:
					possibleStepDown = true
					possibleStepUp = false
		elif not _stepUp and distToPlayer < -STEP_RAY_VERTICAL_OFFSET_EP: # Only check for upwards steps if the point has a more than trivial elevation
			_aimStepCast(groundPoint)

			# Confirm the collision point exists and is a step
			if stepCast.is_colliding() and stepCast.get_collision_normal().angle_to(Vector3(0, 1, 0)) > MAX_SLOPE_ANGLE:
				# We have only verified that the collision point is a steep unclimbable wall of some sort. The player
				# will only engage in step-up logic when the vertical normal of the point that was hit is walkable
				possibleStepUp = true
				possibleStepDown = false
	

	_player.velocity = velocity

	# We have validated the steps, now we will check the ground
	# The player may be either:
	# - on the ground AND stepping OR not stepping
	# - NOT on the ground and NOT stepping

	_aimDownCast(groundPoint)
	var groundNormal := downCast.get_collision_normal()
	var groundAngle := groundNormal.angle_to(Vector3.UP) # 0.0 if groundNormal != Vector3.UP else groundNormal.angle_to(Vector3.UP)

	if groundAngle <= MAX_SLOPE_ANGLE: # The player is on walkable ground
		if groundAngle != 0.0 and distToPlayer < SLOPE_SNAP_LENGTH:
			if not possibleStepDown and distToPlayer > 0: # Snap player to the ground only when going down slopes
				_player.position.y -= distToPlayer
				distToPlayer = 0

			# Project velocity to the slope
			_player.velocity = (_player.velocity - _player.velocity.dot(groundNormal) * groundNormal).normalized() * _player.velocity.length()
		
		# The above block is for slopes. Logic for stepping is enabled and will follow after the player has moved
	else: # The player is not on walkable ground, and we will unset it's possible stepping status
		# We don't need to check for groundedness, as the player will remain airborne on a unwalkable slope

		possibleStepDown = false
		possibleStepUp = false
		_stepDown = false
		_stepUp = false


	# Move the player based on the calculated velocity
	_player.move_and_slide()

	# Stepping logic
	# At this point, if either of the stepping flags are true, the player will be on walkable ground. We don't need to check for that anymore
	if possibleStepDown and stepDownDist > 0 and stepDownDist <= MAX_STEP_HEIGHT + COLLISION_EPSILON:
		_stepDown = true
		_stepUp = false
	elif possibleStepUp and distToPlayer < 0 and distToPlayer >= -MAX_STEP_HEIGHT - COLLISION_EPSILON:
		_stepUp = true
		_stepDown = false


	# Snap player to the ground if the difference is negligable

	if not _attachToGround:
		return

	groundCast.force_shapecast_update()
	if abs(_vertDistToPlayer(_highestGroundPointGlobal())) < COLLISION_EPSILON: # The player is snapped to the ground if they are close enougth
		_player.global_position.y = groundPoint.y
	
	_lastDistToGround = distToPlayer


func snapToFloor() -> void:
	#groundCast.force_shapecast_update()
	#var groundPoint := _highestGroundPointGlobal()
	#_player.global_position.y = groundPoint.y
	pass



# Floor math

# func groundCollisionPointGlobal() -> Vector3:
# func groundCollisionPointNormal() -> Vector3
# func distanceToGround() -> float:



# Collision state check

func grounded(buffered : bool = false) -> bool:
	if buffered:
		return _lastDistToGround < -JUMP_BUFFER

	if _attachToGround:
		return _grounded
	else:
		return _trueGrounded

func groundedOnly(buffered : bool = false) -> bool:
	return grounded(buffered) and not _player.is_on_ceiling() and not _player.is_on_wall()


func attachGround() -> void:
	_attachToGround = true

func unattachGround() -> void:
	_attachToGround = false

func attachedToGround() -> bool:
	return _attachToGround

#endregion


#region Private functions

# Initialization functions

func _configureHitboxes() -> void:
	await _model.player.ready

	_player = _model.player

	_groundCast.add_exception(_player as CollisionObject3D)
	_groundCast.max_results = MAX_COLLISIONS

	_groundCastShape = _groundCast.shape as SphereShape3D
	_groundCastShape.radius = maxf(_player.BODY_COLLIDER_RADIUS - GROUND_CAST_RADIUS_DIFFERENCE, 0.1)

func _configureLedgeDetection() -> void:
	pass


# Aim supplementary raycasts

func _aimDownCast(pos : Vector3) -> void:
	_downCast.global_position = Vector3(pos.x, pos.y + 1, pos.z) # Should be enougth to always hit the point

	_downCast.force_raycast_update()

func _aimStepCast(pos : Vector3) -> void:
	stepCast.global_position = Vector3(_player.global_position.x, pos.y - STEP_RAY_VERTICAL_OFFSET, _player.global_position.z)
	stepCast.target_position = stepCast.to_local(pos) * 4
	stepCast.target_position.y = 0

	stepCast.force_raycast_update()


# Collision point functions

func _highestGlobalGroundPoint() -> Vector3:
	assert(_groundCast.is_colliding(), "PlayerPhysics._highestGlobalGroundPoint(): The player ground detection cast is not colliding. Always check collisions first!")

	var result : Vector3 = _groundCast.get_collision_point(0)
	_currentGroundPointIndex = 0

	for i in range(1, _groundCast.get_collision_count()):
		var curr := _groundCast.get_collision_point(i)

		if curr.y > result.y:
			result = curr
			_currentGroundPointIndex = i
	
	return result

func _vertDistToPlayer(globalPos : Vector3) -> float:
	return _player.global_position.y - globalPos.y


# Debug functionality
func DEBUG_drawCollisionPoints() -> void:
	if groundCast.is_colliding():
		var points : PackedVector3Array
		for i in range(groundCast.get_collision_count()):
			var pt := groundCast.get_collision_point(i)

			points.push_back(pt)
			DebugDraw3D.draw_arrow(pt, pt + groundCast.get_collision_normal(i), Color.PINK, 0.05)

		DebugDraw3D.draw_points(points, DebugDraw3D.POINT_TYPE_SQUARE, 0.1, Color.CRIMSON)

	if downCast.is_colliding():
		var pt := downCast.get_collision_point()
		var points : PackedVector3Array
		points.push_back(pt)
		DebugDraw3D.draw_points(points, DebugDraw3D.POINT_TYPE_SQUARE, 0.1, Color.PURPLE)
		DebugDraw3D.draw_arrow(pt, pt + downCast.get_collision_normal(), Color.DARK_MAGENTA, 0.05)

	if stepCast.is_colliding():
		var pt := stepCast.get_collision_point()
		var points : PackedVector3Array
		points.push_back(pt)
		DebugDraw3D.draw_points(points, DebugDraw3D.POINT_TYPE_SQUARE, 0.1, Color.TURQUOISE)
		DebugDraw3D.draw_arrow(pt, pt + stepCast.get_collision_normal(), Color.DARK_TURQUOISE, 0.05)

#endregion
"""
