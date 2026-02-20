# This script acts as a hub for signals so that these can be emited without having to define who is listening
extends Node

func _ready() -> void:
	# This ensures the script keeps running even when get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

# --- UI SIGNALS ---
signal menuRequested(menu_index: int) # For switching sub-menus
signal backRequested()                # For the "Escape" or "Back" logic

# --- GAME FLOW SIGNALS ---
signal startSceneRequested(level_path: String)
signal gamePaused(is_paused: bool)
signal game_resumed()

# --- DATA SIGNALS ---
signal settings_updated() # When volume or graphics change
