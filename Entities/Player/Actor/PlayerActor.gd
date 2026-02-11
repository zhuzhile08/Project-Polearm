extends CharacterBody3D
class_name PlayerActor


#region Scene Members

@onready var inputManager := $InputManager as PlayerInputManager
@onready var model := $Model as PlayerModel

#endregion


#region Member variables

@onready var profile := PlayerProfile.new()

#endregion


#region Built-in functions

func _ready() -> void:
	# cameraAxis.init(self)
	pass


func _physics_process(delta: float) -> void:
	inputManager.pollInputs()
	model.tick(inputManager.inputs, delta)

#endregion
