extends Node

enum GameState { MAIN_MENU, PLAYING, PAUSED, LOADING }
var current_state: GameState = GameState.MAIN_MENU

func _ready() -> void:
	# This ensures the script keeps running even when get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Listen for the start request
	SignalBus.startSceneRequested.connect(_on_start_game)

func _process(_delta: float) -> void:
	# Global Input Handling
	if Input.is_action_just_pressed("ui_cancel"): # Usually Escape
		_handleEscapeLogic()
	if Input.is_key_pressed(KEY_P):
		print(current_state)

func _on_start_game(_path: String) -> void:
	current_state = GameState.PLAYING
	SceneLoader.load_level(_path)

func _handleEscapeLogic() -> void:
	match current_state:
		GameState.MAIN_MENU:
			# On the Main Menu, Escape might do nothing or show a "Quit" pop-up
			SignalBus.backRequested.emit()
		
		GameState.PLAYING:
			# If playing, Escape pauses the game
			toggle_pause(true)
		
		GameState.PAUSED:
			# If already paused, Escape goes back in the menu or resumes
			SignalBus.backRequested.emit()

func toggle_pause(should_pause: bool) -> void:
	get_tree().paused = should_pause
	if should_pause:
		current_state = GameState.PAUSED
	else:
		current_state = GameState.PLAYING
	
	SignalBus.gamePaused.emit(should_pause)
