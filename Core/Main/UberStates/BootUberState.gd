extends UberState
class_name BootUberState


@export var _mainMenu : MainMenuUberState = null


func _ready() -> void:
	assert(_mainMenu != null, "BootUberState._ready(): Main menu wasn't assigned!")

	super._ready()


#region Implementation functions

func type() -> Type:
	return Type.boot

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	_sceneResource = null # Also delete the scene resource, as we only boot once


func nextState() -> Type:
	if not scene.readyToSwitch() and not _mainMenu.finishedLoading():
		return Type.none

	return Type.mainMenu

#endregion
