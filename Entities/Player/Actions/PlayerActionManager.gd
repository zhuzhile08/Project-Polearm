extends Node
class_name PlayerActionManager


#region Scene members

@export_category("Scene members")
@export var model : PlayerModel
@export var resources : PlayerResources
@export var combatManager : PlayerCombatManager
@export var actionData : PlayerActionData

var player : Player
var cameraManager : PlayerCameraManager

#endregion


#region Member variables

var actions : Dictionary[Player.ActionType, PlayerAction]

#endregion


#region Built-in functions

func _ready() -> void:
	assert(model != null, "PlayerActionManager._ready(): Player model not assigned!")
	assert(resources != null, "PlayerActionManager._ready(): Player resources not assigned!")
	assert(combatManager != null, "PlayerActionManager._ready(): Player combat manager not assigned!")
	assert(actionData != null, "PlayerActionData._ready(): Player action data not assigned!")

	player = model.player
	cameraManager = model.cameraManager

	for child in get_children():
		if child is PlayerAction:
			child.init(player, self, combatManager, cameraManager, actionData, resources)
			actions[child.TYPE] = child

#endregion


#region Public functions

func actionPrioritySort(a : Player.ActionType, b : Player.ActionType) -> bool:
	if actions[a].PRIORITY > actions[b].PRIORITY:
		return true
	return false

#endregion
