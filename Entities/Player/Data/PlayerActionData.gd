extends AnimationPlayer
class_name PlayerActionData


#region Exported action properties

@export_category("Animation")
@export var _transitionable : bool = true # originally false
# @export var interruptable : bool = true # I do not understand the purpose of why I added this, uncomment if it is useful and explain the difference between this and the option above
@export var _trackDirection : bool = false # If an action tracks the direction of the input, it also tracks the direction of the camera

@export_category("Movement")
@export var _mimicRootMotion : bool = false
@export var _rootMotionVelocityFactor : float = 1

@export_category("Combat")
@export var _vulnerable : bool = true
@export var _acceptsQueue : bool = false

# Certain combos in the game require the player to wait a small amount of time before before inputting the next move. This variable denotes
# from when on the combat manager will insert a pause into the combo upon pressing an input instead of just inserting the action normally
@export var _comboPause : bool = false

#endregion


#region Public functions

func transitionable(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_transitionable", time)

# func animInterruptable(animationName : String, time : float) -> bool:
#	return _getBooleanValue(animationName, "ActionData:interruptable", time)

func trackDirection(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_trackDirection", time)


func mimicRootMotion(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_mimicRootMotion", time)

func rootMotionVelocityFactor(animationName : String, time : float) -> bool:
	return _getFloatingValue(animationName, "ActionData:_rootMotionVelocityFactor", time)


func vulnerable(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_vulnerable", time)

func comboPause(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_comboPause", time)

func acceptsQueue(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_acceptsQueue", time)

#endregion


#region Private functions

func _getBooleanValue(animationName : String, propertyName : String, time : float) -> bool:
	var anim = get_animation(animationName)
	return anim.value_track_interpolate(anim.find_track(propertyName, Animation.TrackType.TYPE_VALUE), time)

func _getFloatingValue(animationName : String, propertyName : String, time : float) -> float:
	var anim = get_animation(animationName)
	return anim.value_track_interpolate(anim.find_track(propertyName, Animation.TrackType.TYPE_VALUE), time)

#endregion
