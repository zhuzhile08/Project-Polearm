extends CanvasLayer
class_name InterfaceController

@export var game_scene : PackedScene
enum subMenus { MainMenu, OptionsMenu, PauseMenu, OptionsInterface, Game, Video, Audio, Controller, Keyboard }
static var menuHistory: Array = []
@onready var menuMapping = {
	subMenus.MainMenu: $MainMenu,
	subMenus.OptionsMenu: $OptionsMenu,
	subMenus.PauseMenu: $PauseMenu
}

static func switchMenuTo(target: int, mapping: Dictionary) -> void:
	for menus in mapping.values():
		menus.hide()
	
	var targetMenu = mapping[target]
	menuHistory.append(targetMenu)
	print(menuHistory)
	menuHistory.back().show()
	
	var firstButton = targetMenu.find_next_valid_focus()
	if firstButton:
		firstButton.grab_focus()

static func menuGoBack() -> void:
	menuHistory.back().hide()
	menuHistory.pop_back()
	print(menuHistory)
	menuHistory.back().show()

func _ready() -> void:
	switchMenuTo(subMenus.MainMenu, menuMapping)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		menuGoBack()

func _start_game() -> void: # Main Menu Button
	var gameplay_instance = game_scene.instantiate()
	add_child(gameplay_instance)
	$MainMenu.hide()

func _new_game() -> void: # Main Menu Button
	pass # Replace with function body.

func _open_options() -> void:# Main Menu & Pause Menu Button
	switchMenuTo(subMenus.OptionsMenu, menuMapping)

func _exit_game() -> void: # Main Menu Button
	get_tree().quit()

func _continue() -> void: # Pause Menu Button
	$PauseMenu.hide()
	get_tree().paused = false

func _open_main_menu() -> void: # Pause Menu Button
	switchMenuTo(subMenus.MainMenu, menuMapping)
