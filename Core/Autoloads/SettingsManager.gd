extends Node

const SETTINGS_PATH = "user://settings.cfg"
var config = ConfigFile.new()

# Default values
var Settings = {
	"game": {},
	"video": 
		{"fullscreen": true, 
		"resolution": Vector2i(1920, 1080)},
	"audio": 
		{"master": 0.8, 
		"music": 0.8, 
		"sfx": 0.8},
	"controller": {},
	"keyboard": {}
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	loadSettings()

func loadSettings():
	var error = config.load(SETTINGS_PATH)
	
	if error != OK:
		print("No settings file found. Creating defaults...")
		saveSettings() # Create the file for the first time
		return

	# Load Audio
	Settings.audio.master = config.get_value("audio", "master", 0.8)
	apply_audio_settings("Master", Settings.audio.master)
	
	# Load Video
	Settings.video.fullscreen = config.get_value("video", "fullscreen", true)
	apply_video_settings(Settings.video.fullscreen)

func saveSettings():
	for section in Settings.keys():
		for key in Settings[section].keys():
			config.set_value(section, key, Settings[section][key])
	config.save(SETTINGS_PATH)

# --- APPLY FUNCTIONS ---

func apply_audio_settings(bus_name: String, value: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	# Converts linear 0.0-1.0 to Decibels
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	Settings.audio[bus_name.to_lower()] = value

func apply_video_settings(is_fullscreen: bool):
	var mode = Window.MODE_FULLSCREEN if is_fullscreen else Window.MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	Settings.video.fullscreen = is_fullscreen
