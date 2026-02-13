extends Node3D
class_name PlayerModel


#region Scene members

@export_category("Scene members")
@export var actor : PlayerActor

@onready var resources := $Resources as PlayerResources
@onready var actionManager := $ActionManager as PlayerActionManager
@onready var combatManager := $CombatManager as PlayerCombatManager
@onready var actionData := $ActionData as PlayerActionData

#endregion


#region Member variables

var currentAction : PlayerAction = null

#endregion


#region Built-in functions

func _ready() -> void:
	assert(actor != null, "PlayerModel._ready(): Player actor not assigned!")

	actionManager.init(actor, resources, combatManager, actionData)

	currentAction = actionManager.actions[Player.ActionType.idle]
	switchTo(Player.ActionType.idle)

#endregion


#region Public functions

func tick(input : PlayerInputManager.Data, delta: float) -> void:
	processInput(input)
	
	var nextAction := currentAction.nextAction(input)
	if nextAction != Player.ActionType.none:
		switchTo(nextAction)
	
	currentAction.tick(input, delta)
	combatManager.tick(delta)
	resources.tick(delta)


# Input processing by sorting them by priority
func processInput(input : PlayerInputManager.Data):
	input.actions.sort_custom(actionManager.actionPrioritySort)
	
	# Check sidearm --> What did I mean by this?
	
	#


# Forces a swith to a given action type
func switchTo(action : Player.ActionType) -> void:
	currentAction.exit()
	currentAction = actionManager.actions[action]
	currentAction.enter()

#endregion
