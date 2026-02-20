extends Node

@onready var worldContainer = $WorldContainer

func _ready():
	SceneLoader.worldContainer = worldContainer
	GameManager.current_state = GameManager.GameState.MAIN_MENU
	SceneLoader.load_level("res://Stages/MainMenuBackground.tscn")

	# Connect the UI to the global signal bus
	SignalBus.gamePaused.connect(_onPause)

func _onPause(is_paused: bool):
	print("Main scene is reacting to the global pause signal!")
