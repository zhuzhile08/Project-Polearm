extends Control

@onready var optionsMenu := $Options as CenterContainer
@onready var buttons := $Buttons as MenuButtonManager


# Menu actions

func playButtonPressed() -> void:
	get_tree().change_scene_to_file("res://Stages/Main.tscn")
	
func optionsButtonPressed() -> void:
	buttons.hide()
	optionsMenu.show()
	
func quitButtonPressed() -> void:
	get_tree().quit()

func optionsMenuQuit() -> void:
	optionsMenu.hide()
	buttons.show()


func DEBUG_setInitialVisibility():
	for child in get_children():
		child.hide()
	
	$Buttons.show()

func _ready() -> void:
	DEBUG_setInitialVisibility()
