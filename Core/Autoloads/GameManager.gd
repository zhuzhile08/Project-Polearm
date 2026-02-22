extends Node

enum GameState { MAINMENU, PLAYING, PAUSED, LOADING }
var current_state: GameState = GameState.MAINMENU

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connecting SignlaBus signals
	SignalBus.startSceneRequested.connect(startGame)
	SignalBus.goMainMenu.connect(goMainMenu)
	SignalBus.intention.connect(receiveIntention)

# --- Input Intentions ---
func receiveIntention(intention: String) -> void:
	match intention:
		"cancelOrPause":
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

func toggle_pause(should_pause: bool) -> void:
	get_tree().paused = should_pause
	if should_pause:
		current_state = GameState.PAUSED
	else:
		current_state = GameState.PLAYING
	
	SignalBus.gamePaused.emit(should_pause)

# --- Changes to GameState ---
func startGame(_path: String) -> void:
	current_state = GameState.PLAYING
	SceneLoader.loadLevel(_path)

func goMainMenu() -> void:
	current_state = GameState.MAINMENU
	SceneLoader.loadLevel("res://Stages/MainMenuBackground.tscn")
