extends Node

@onready var worldContainer = $WorldContainer

func _ready():
	SceneLoader.worldContainer = worldContainer
	SignalBus.goMainMenu
