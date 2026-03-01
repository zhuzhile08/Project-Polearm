extends InterfaceState


var _onGameOptionsPressed: bool = false
var _onVideoOptionsPressed: bool = false
var _onAudioOptionsPressed: bool = false
var _onControllerOptionsPressed: bool = false
var _onKeyboardOptionsPressed: bool = false

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
	
func nextMenu(inputs : MainInputManager.Data) -> Type:
	if inputs.cancel:
		pass
	
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
