extends Node
class_name PlayerAction

# Configurable variables

@export_category("General")
@export var TYPE : Player.ActionType
@export var PRIORITY : int = 0
@export var DEFAULT_ANIMATION : String

@export_category("Combat")
@export var ENERGY_COST : float = 0
@export var QUEUEABLE : bool = false


# Member variables

var actor : CharacterBody3D
var resources : PlayerResources
var combatManager : PlayerCombatManager
var actionData : PlayerActionData

@onready var manager := $".." as PlayerActionManager


var progress : float
var DURATION : float

var queue : Player.ActionType = Player.ActionType.none
var next : Player.ActionType = Player.ActionType.none

@onready var animation : String = DEFAULT_ANIMATION


# Member functions

# Exposed interface

# This checks if the current action should continue or a transition should happen
func nextAction(input : PlayerInputManager.Data) -> Player.ActionType:
	if acceptsQueue():
		checkAndSetQueue(input)
	
	if queue != Player.ActionType.none && canTransition():
		checkAndSetNext(queue)
	
	if next != Player.ActionType.none:
		return next

	return highestPriorityAction(input)


func init() -> void:
	pass

# This is called on every frame when the action is enabled
func update(input : PlayerInputManager.Data, delta : float) -> void:
	progress += delta

	if actionData.animTracksDirection(animation, progress):
		processDirection(input, delta)
	
	updateImpl(input, delta)

# This is executed on action enter
func enter() -> void:
	resources.payAction(self)
	
	if combatManager.isNextComboAction(TYPE):
		animation = combatManager.registerComboAction(TYPE)
		
		# Play animation
	
	enterImpl()

# This is executed on action exit and resets the action to prepare it for the next time it's activated
func exit() -> void:
	exitImpl()
	
	progress = 0
	
	animation = DEFAULT_ANIMATION
	queue = Player.ActionType.none
	next = Player.ActionType.none


# Internal functions

# Check if the action can accept a queue (i.e. the animation has progressed enough for the move to be queueable)
func acceptsQueue() -> bool:
	return actionData.animAcceptsQueue(animation, progress)

# Check if the action can start it's transition to another action
func canTransition() -> bool:
	return actionData.animTransitionable(animation, progress)


# Check if a queueable move is present, can be queued with the current action and set it if these are the case
func checkAndSetQueue(input : PlayerInputManager.Data) -> void:
	if input.actions.size() == 0:
		return
	
	if actionData.animComboPause(animation, progress) && combatManager.isNextComboAction(Player.ActionType.idle):
		combatManager.registerComboAction(Player.ActionType.idle)
	
	if manager.actions[input.actions[0]].QUEUEABLE:
		queue = input.actions[0]

# Check if the next action can be set (i.e. has a higher priority than the current next action)
func checkAndSetNext(action : Player.ActionType) -> void:
	if next == Player.ActionType.none || manager.actions[next].PRIORITY >= PRIORITY:
		next = action


# Gets the highest priority action from the current input package or wait
func highestPriorityAction(input : PlayerInputManager.Data) -> Player.ActionType:
	# Go through all higher priority actions and immediately return them if possible as they can cancel the current action
	for actionType in input.actions:
		var action = manager.actions[actionType]
		
		# If both animations have the same type, just ignore it and break
		# If the current action is not yet finished and the other has the same priority, don't play the animation
		if action.TYPE == TYPE or action.PRIORITY <= PRIORITY and progress < DURATION:
			break # We can directly break instead of continuing, since the actions are sorted
		
		if resources.canAffordAction(action):
			return actionType
	
	return Player.ActionType.none


# If enabled, this will influence the direction the player faces using the direction of the input package
func processDirection(input : PlayerInputManager.Data, delta : float) -> void:
	pass


# Implementation functions, usually overwritten

func updateImpl(input : PlayerInputManager.Data, delta : float) -> void:
	pass

func enterImpl() -> void:
	pass

func exitImpl() -> void:
	pass
