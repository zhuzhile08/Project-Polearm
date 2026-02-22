extends Node

enum GameState { MAINMENU, PLAYING, PAUSED, LOADING }
var current_state: GameState = GameState.MAINMENU

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connecting SignlaBus signals
	SignalBus.startSceneRequested.connect(startGame)
	SignalBus.mainMenuRequested.connect(goMainMenu)
	SignalBus.intentionReceived.connect(receiveIntention)

# --- Input Intentions ---
func receiveIntention(intention: SignalBus.Intent) -> void:
	match intention:
		SignalBus.Intent.CANCELORPAUSE:
			handleEscapeLogic()

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
