extends Node
class_name PlayerActionManager

var actor : CharacterBody3D

var model : PlayerModel
var resources : PlayerResources
var combatManager : PlayerCombatManager
var actionData : PlayerActionData

var actions : Dictionary[Player.ActionType, PlayerAction]


func init() -> void:
	for child in get_children():
		if child is PlayerAction:
			child.actor = actor
			child.resources = resources
			child.combatManager = combatManager
			child.actionData = actionData
			
			actions[child.TYPE] = child
			child.init()


func actionPrioritySort(a : Player.ActionType, b : Player.ActionType) -> bool:
	if actions[a].PRIORITY > actions[b].PRIORITY:
		return true
	return false
