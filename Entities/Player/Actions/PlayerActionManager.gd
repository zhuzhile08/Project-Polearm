extends Node
class_name PlayerActionManager


# var actor : CharacterBody3D
# var model : PlayerModel
# var resources : PlayerResources
# var combatManager : PlayerCombatManager
# var actionData : PlayerActionData


#region Member variables

var actions : Dictionary[Player.ActionType, PlayerAction]

#endregion


#region Public functions

func init(actor : PlayerActor, resources : PlayerResources, combatManager : PlayerCombatManager, actionData : PlayerActionData) -> void:
	for child in get_children():
		if child is PlayerAction:
			child.init(self, actor, resources, combatManager, actionData)
			actions[child.TYPE] = child


func actionPrioritySort(a : Player.ActionType, b : Player.ActionType) -> bool:
	if actions[a].PRIORITY > actions[b].PRIORITY:
		return true
	return false

#endregion
