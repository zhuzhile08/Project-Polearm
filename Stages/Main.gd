extends Node

@onready var worldContainer = $WorldContainer

func _ready():
	SceneLoader.registerWorldContainer(worldContainer)
	SignalBus.mainMenuRequested.emit()
