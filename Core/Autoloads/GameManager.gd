extends Node

enum GameState { MAINMENU, PLAYING, PAUSED, LOADING }
var current_state: GameState = GameState.MAINMENU

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connecting SignlaBus signals
	SignalBus.startSceneRequested.connect(startGame)
	SignalBus.mainMenuRequested.connect(goMainMenu)
	SignalBus.intentionReceived.connect(receiveIntention)

func _input(event: InputEvent) -> void:
	updateMouseVisibility(event)
	
# --- Input Intentions ---
func receiveIntention(intention: SignalBus.Intent) -> void:
	match intention:
		SignalBus.Intent.CANCELORPAUSE:
			handleEscapeLogic()
			
		SignalBus.Intent.CANCELORSHOOT:
			handleControllerBLogic()

func handleEscapeLogic() -> void:
	match current_state:
		GameState.MAINMENU:
			# On the Main Menu, Escape might do nothing or show a "Quit" pop-up
			SignalBus.backRequested.emit()
		
		GameState.PLAYING:
			# If playing, Escape pauses the game
			toggle_pause(true)
		
		GameState.PAUSED:
			# If already paused, Escape goes back in the menu or resumes
			SignalBus.backRequested.emit()

func handleControllerBLogic() -> void:
	match current_state:
		GameState.MAINMENU:
			# On the Main Menu, B might do nothing or show a "Quit" pop-up
			SignalBus.backRequested.emit()
		
		GameState.PLAYING:
			pass
		
		GameState.PAUSED:
			# If already paused, B goes back in the menu or resumes
			SignalBus.backRequested.emit()

func updateMouseVisibility(event: InputEvent) -> void:
	if event is InputEventMouse:
		return
		
		# Handels the visibility of the mouse depending on the gamestate and last input
	if current_state == GameState.PLAYING:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		if event is InputEventKey or event is InputEventJoypadButton or event is InputEventJoypadMotion:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# --- Changes to GameState ---
func changeGameState(targetState: GameState) -> void:
	current_state = targetState
	
func toggle_pause(should_pause: bool) -> void:
	get_tree().paused = should_pause
	if should_pause:
		changeGameState(GameState.PAUSED)
	else:
		changeGameState(GameState.PLAYING)
	
	SignalBus.gamePauseRequested.emit(should_pause)

func startGame(_path: String) -> void:
	changeGameState(GameState.PLAYING)
	get_tree().paused = false
	SceneLoader.loadLevel(_path)

func goMainMenu() -> void:
	changeGameState(GameState.MAINMENU)
	get_tree().paused = false
	SceneLoader.loadLevel("res://Stages/MainMenuBackground.tscn")
