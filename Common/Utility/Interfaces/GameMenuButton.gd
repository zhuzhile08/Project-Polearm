extends PanelContainer
class_name GameMenuButton

@export var NAME : String

@onready var button := $Button as Button

signal buttonPressed


func onButtonPressed() -> void:
	buttonPressed.emit()


func _ready() -> void: ### Change to _init if necessary
	button.text = NAME
	button.mouse_entered.connect(button.grab_focus)


func _process(delta: float) -> void:
	pass
