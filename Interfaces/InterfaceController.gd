extends CanvasLayer
class_name InterfaceController

enum SubMenus { MAIN, OPTIONS, PAUSE }

# Local variable to track history
var menuHistory: Array[Control] = []

@onready var menuMapping = {
	SubMenus.MAIN: $MainMenu,
	SubMenus.OPTIONS: $OptionsMenu,
	SubMenus.PAUSE: $PauseMenu
}

func _ready() -> void:
	# Connect to the Wiring (SignalBus)
	SignalBus.backRequested.connect(menuGoBack)
	SignalBus.menuRequested.connect(switchMenuTo)
	SignalBus.gamePaused.connect(_onGamePaused)
	
	# 2. Start at Main Menu
	switchMenuTo(SubMenus.MAIN)

# --- THE LOGIC ---
func hideMenu() -> void:
	for menu in menuMapping.values():
		menu.hide()
	
func switchMenuTo(target: int) -> void:
	# Hide everything first
	hideMenu()
	var targetMenu = menuMapping[target]
	
	# Add to history if it's not already the top
	if target == SubMenus.PAUSE or target == SubMenus.MAIN:
		menuHistory.clear()
		
	menuHistory.append(targetMenu)
	targetMenu.show()
	
	# Focus for controller support
	grabFirstButton()

func menuGoBack() -> void:
	# Check if we can actually go back
	if menuHistory.size() <= 1:
		# If we are in the Main Menu, maybe ask "Quit Game?"
		# If we are Paused, just unpause
		if GameManager.current_state == GameManager.GameState.PAUSED:
			GameManager.toggle_pause(false)
		return

	# Normal back logic
	menuHistory.back().hide()
	menuHistory.pop_back()
	menuHistory.back().show()
	
	grabFirstButton()

# --- SIGNAL REACTIONS ---

func _onGamePaused(is_paused: bool) -> void:
	if is_paused and GameManager.current_state != GameManager.GameState.MAIN_MENU:
		switchMenuTo(SubMenus.PAUSE)
	else:
		# Hide all menus when resuming
		hideMenu()
		menuHistory.clear()

# --- BUTTON LINKS (Call these from your Button signals) ---

func _onPlayPressed() -> void:
	# Tell the SceneLoader to take over!
	GameManager.current_state = GameManager.GameState.PLAYING
	SignalBus.startSceneRequested.emit("res://Stages/ShaderTest.tscn")
	menuHistory.clear()
	hideMenu()

func grabFirstButton() -> void:
	var firstButton = menuHistory.back().find_next_valid_focus()
	if firstButton:
		firstButton.grab_focus()

func _onOptionsPressed() -> void:
	switchMenuTo(SubMenus.OPTIONS)

func _onExitPressed() -> void:
	get_tree().quit()


func _openMainMenu() -> void:
	switchMenuTo(SubMenus.MAIN)
	SceneLoader.load_level("res://Stages/MainMenuBackground.tscn")
	GameManager.current_state = GameManager.GameState.MAIN_MENU
