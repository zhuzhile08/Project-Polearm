extends InterfaceState


#region Export variables

@export var BACK_MENU : Type

#endregion


#region Member variables

var _onGameOptionsPressed : bool = false
var _onVideoOptionsPressed : bool = false
var _onAudioOptionsPressed : bool = false
var _onControllerOptionsPressed : bool = false
var _onKeyboardOptionsPressed : bool = false

#endregion


#region Implementation functions

func type() -> Type:
	return Type.options

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel:
		return BACK_MENU
		
	if _onGameOptionsPressed:
		return Type.gameOptions
		
	if _onVideoOptionsPressed:
		return Type.videoOptions
	
	if _onAudioOptionsPressed:
		return Type.audioOptions
	
	if _onControllerOptionsPressed:
		return Type.controllerOptions
	
	if _onKeyboardOptionsPressed:
		return Type.keyboardOptions
	
	return Type.none

func deactivateImpl() -> void:
	_onGameOptionsPressed = false
	_onVideoOptionsPressed = false
	_onAudioOptionsPressed = false
	_onControllerOptionsPressed = false
	_onKeyboardOptionsPressed = false

#endregion


#region Signal functions

func _on_game_pressed() -> void:
	_onGameOptionsPressed = true

func _on_video_pressed() -> void:
	_onVideoOptionsPressed = true

func _on_audio_pressed() -> void:
	_onAudioOptionsPressed = true

func _on_controller_pressed() -> void:
	_onControllerOptionsPressed = true

func _on_keyboard_pressed() -> void:
	_onKeyboardOptionsPressed = true

#endregion
