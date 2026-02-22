extends Node

const SETTINGS_PATH = "user://settings.cfg"
var config = ConfigFile.new()

# Default values
var _settings = {
	"audio": {"master": 0.8, "music": 0.8, "sfx": 0.8},
	"video": {"fullscreen": true, "resolution": Vector2i(1920, 1080)}
}

func _ready():
	# This ensures the script keeps running even when get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()

func load_settings():
	var error = config.load(SETTINGS_PATH)
	
	if error != OK:
		print("No settings file found. Creating defaults...")
		save_settings() # Create the file for the first time
		return

	# Load Audio
	_settings.audio.master = config.get_value("audio", "master", 0.8)
	apply_audio_settings("Master", _settings.audio.master)
	
	# Load Video
	_settings.video.fullscreen = config.get_value("video", "fullscreen", true)
	apply_video_settings(_settings.video.fullscreen)

func save_settings():
	for section in _settings.keys():
		for key in _settings[section].keys():
			config.set_value(section, key, _settings[section][key])
	config.save(SETTINGS_PATH)

# --- APPLY FUNCTIONS ---

func apply_audio_settings(bus_name: String, value: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	# Converts linear 0.0-1.0 to Decibels
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	_settings.audio[bus_name.to_lower()] = value

func apply_video_settings(is_fullscreen: bool):
	var mode = Window.MODE_FULLSCREEN if is_fullscreen else Window.MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	_settings.video.fullscreen = is_fullscreen
