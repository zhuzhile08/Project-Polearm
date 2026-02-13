extends AnimationPlayer
class_name PlayerActionData


#region Exported action properties

@export_category("Animation")
@export var _transitionable : bool = true # originally false
# @export var interruptable : bool = true # I do not understand the purpose of why I added this, uncomment if it is useful and explain the difference between this and the option above
@export var _trackDirection : bool = false # If an action tracks the direction of the input, it also tracks the direction of the camera

@export_category("Gameplay")
@export var _vulnerable : bool = true
@export var _acceptsQueue : bool = false
@export var _comboPause : bool = false

#endregion


#region Public functions

func transitionable(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_transitionable", time)

# func animInterruptable(animationName : String, time : float) -> bool:
#	return _getBooleanValue(animationName, "ActionData:interruptable", time)

func vulnerable(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_vulnerable", time)

func comboPause(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_comboPause", time)

func acceptsQueue(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_acceptsQueue", time)

func trackDirection(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:_trackDirection", time)

#endregion


#region Private functions

func _getBooleanValue(animationName : String, propertyName : String, time : float) -> bool:
	var anim = get_animation(animationName)
	return anim.value_track_interpolate(anim.find_track(propertyName, Animation.TrackType.TYPE_VALUE), time)

#endregion
