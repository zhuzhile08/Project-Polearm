extends AnimationPlayer
class_name PlayerActionData


#region Exported action properties

@export_category("Animation")
@export var transitionable : bool = true # originally false
# @export var interruptable : bool = true # I do not understand the purpose of why I added this, uncomment if it is useful and explain the difference between this and the option above

@export_category("Gameplay")
@export var vulnerable : bool = true
@export var acceptsQueue : bool = false
@export var comboPause : bool = false
@export var tracksDirection : bool = false

#endregion


#region Public functions

func animTransitionable(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:transitionable", time)

# func animInterruptable(animationName : String, time : float) -> bool:
#	return _getBooleanValue(animationName, "ActionData:interruptable", time)

func animVulnerable(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:vulnerable", time)

func animComboPause(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:comboPause", time)

func animAcceptsQueue(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:acceptsQueue", time)

func animTracksDirection(animationName : String, time : float) -> bool:
	return _getBooleanValue(animationName, "ActionData:tracksDirection", time)

#endregion


#region Private functions

func _getBooleanValue(animationName : String, propertyName : String, time : float) -> bool:
	var anim = get_animation(animationName)
	return anim.value_track_interpolate(anim.find_track(propertyName, Animation.TrackType.TYPE_VALUE), time)

#endregion
