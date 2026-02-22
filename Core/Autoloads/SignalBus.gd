# This script acts as a hub for signals so that these can be emited without having to define who is listening
extends Node

func _ready() -> void:
	# This ensures the script keeps running even when get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

# --- UI SIGNALS ---
signal menuRequested(menuIndex: int)
signal backRequested()

# --- GAME FLOW SIGNALS ---
signal mainMenuRequested()
signal startSceneRequested(levelPath: String)
signal gamePauseRequested(isPaused: bool)

# --- DATA SIGNALS ---
signal settingsUpdated()

# --- INPUT SIGNALS ---
enum Intent { CANCELORPAUSE }
signal intentionReceived(intention: Intent)
