extends Node

const SETTINGS_PATH = "user://settings.cfg"
var config = ConfigFile.new()

# Default values
var Settings : Dictionary = {
	"game": {
		
	},
	"video": {
		"fullscreen": true, 
		"resolution": Vector2i(1920, 1080)
	},
	"audio": {
		"master": 0.8, 
		"music": 0.8, 
		"sfx": 0.8
	},
	"controller": {
		"Light attack": null,
		"Heavy attack": null,
		"Jump": null,
		"Shoot": JOY_BUTTON_B,
		"Target left": null,
		"Target right": null,
		"Dodge": null,
		"Sprint": null,
		"Launcher": null,
		"Held target toggle": null,
		"Move left": JOY_AXIS_LEFT_X,
		"Move right": JOY_AXIS_LEFT_X,
		"Move forwards": JOY_AXIS_LEFT_Y,
		"Move backwards": JOY_AXIS_LEFT_Y,
		"Camera left": null,
		"Camera right": null,
		"Camera up": null,
		"Camera down": null,
		"Switch weapon": null,
		"Taunt": null
	},
	"keyboard": {
		"Light attack": null,
		"Heavy attack": null,
		"Jump": null,
		"Shoot": null,
		"Target left": null,
		"Target right": null,
		"Dodge": null,
		"Sprint": null,
		"Launcher": null,
		"Held target toggle": null,
		"Move left": KEY_A,
		"Move right": KEY_D,
		"Move forwards": KEY_W,
		"Move backwards": KEY_S,
		"Camera left": null,
		"Camera right": null,
		"Camera up": null,
		"Camera down": null,
		"Switch weapon": null,
		"Taunt": null
	}
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
	
	# Load Keyboard
	for action in Settings.keyboard.keys():
		if config.has_section_key("keyboard", action):
			Settings.keyboard[action] = config.get_value("keyboard", action)
		
	# Load Controller
	for action in Settings.controller.keys():
		if config.has_section_key("controller", action):
			Settings.controller[action] = config.get_value("controller", action)
			
	apply_input_settings()
	
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

func apply_input_settings() -> void:
	for actionName in Settings.keyboard:
		# Cleans all the button mappings
		# InputMap.action_erase_events(actionName)
		
		# Adds keyboard binds
		var keyID = Settings.keyboard[actionName]
		
		if Settings.keyboard[actionName] != null:
			var newKey = InputEventKey.new()
			newKey.physical_keycode = keyID
			
			InputMap.action_add_event(actionName, newKey)
		
		# Adds controler joy stick mapping and button mapping
		var conID = Settings.controller[actionName]
		
		if Settings.controller[actionName] != null:
			# Joy stick
			if actionName.contains("Move") or actionName.contains("Camera"):
				var newAxis = InputEventJoypadMotion.new()
				newAxis.axis = conID
				
				if actionName.contains("left") or actionName.contains("forwards") or actionName.contains("up"):
					newAxis.axis_value = -1
				else:
					newAxis.axis_value = 1
					
				InputMap.action_add_event(actionName, newAxis)
				
			# Button
			else:
				var newCon = InputEventJoypadButton.new()
				newCon.button_index = conID
				InputMap.action_add_event(actionName, newCon)
