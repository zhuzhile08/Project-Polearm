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
	SignalBus.gamePaused.connect(onGamePaused)
	
	# 2. Start at Main Menu
	switchMenuTo(SubMenus.MAIN)
	
	for button in get_tree().get_nodes_in_group("hover_buttons"):
		if button is Button:
			button.mouse_entered.connect(focusToMouseHover.bind(button))

# --- Visuals ---
func findAllButtons() -> void:
	var currentMenu = menuHistory.back()
	if not currentMenu:
		return
	
	var buttons = currentMenu.find_children("*", "BaseButton", true, false)
	
	for button in buttons:
		if not button.mouse_entered.is_connected(focusToMouseHover):
			button.mouse_entered.connect(focusToMouseHover.bind(button))

func grabFirstButton() -> void:
	var firstButton = menuHistory.back().find_next_valid_focus()
	if firstButton:
		firstButton.grab_focus()

func focusToMouseHover(button: BaseButton) -> void:
	if not button.has_focus():
		button.grab_focus()

# --- Basic Menu Operations ---
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
	findAllButtons()
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
	
	findAllButtons()
	grabFirstButton()

# --- SIGNAL REACTIONS ---
func onGamePaused(is_paused: bool) -> void:
	if is_paused and GameManager.current_state != GameManager.GameState.MAINMENU:
		switchMenuTo(SubMenus.PAUSE)
	else:
		# Hide all menus when resuming
		hideMenu()
		menuHistory.clear()

# --- BUTTON LINKS (Call these from the Button signals) ---
func onPlayPressed() -> void:
	# Tell the SceneLoader to take over!
	SignalBus.startSceneRequested.emit("res://Stages/ShaderTest.tscn")
	menuHistory.clear()
	hideMenu()

func onOptionsPressed() -> void:
	switchMenuTo(SubMenus.OPTIONS)

func onQuitGamePressed() -> void:
	get_tree().quit()

func onMainMenuPressed() -> void:
	switchMenuTo(SubMenus.MAIN)
	SignalBus.goMainMenu.emit()

func onContinuePressed() -> void:
	menuGoBack()
