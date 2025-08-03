extends Node3D
class_name PlayerModel

var currentAction : PlayerAction

@onready var actor := $".." as CharacterBody3D
@onready var resources := $Resources as PlayerResources
@onready var actionManager := $ActionManager as PlayerActionManager
@onready var combatManager := $CombatManager as PlayerCombatManager
@onready var actionData := $ActionData as PlayerActionData


func _ready() -> void:
	actionManager.model = self
	actionManager.actor = actor
	actionManager.resources = resources
	actionManager.combatManager = combatManager
	actionManager.actionData = actionData
	actionManager.init()

	currentAction = actionManager.actions[Player.ActionType.idle]
	switchTo(Player.ActionType.idle)


func update(input : PlayerInputPackage, delta: float) -> void:
	input = checkInput(input)
	
	var nextAction = currentAction.nextAction(input)
	if nextAction != Player.ActionType.none:
		switchTo(nextAction)
	
	currentAction.update(input, delta)
	combatManager.update(delta)
	resources.update(delta)


func checkInput(input : PlayerInputPackage) -> PlayerInputPackage:
	# Sort inputs
	input.actions.sort_custom(actionManager.actionPrioritySort)
	
	# Check sidearm
	
	# 
	
	return input


func switchTo(action : Player.ActionType) -> void:
	currentAction.exit()
	currentAction = actionManager.actions[action]
	currentAction.enter()
