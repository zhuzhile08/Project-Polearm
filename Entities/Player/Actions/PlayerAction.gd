extends Node
class_name PlayerAction


#region Enums

enum Priority {
	idle = 0,
	groundedMovementTypes = 1,
	interactionTypes = 10,
	fallingTypes = 20,
	jumpingTypes = 30,
	combatTypes = 40,
	evasionTypes = 50,
	damageTypes = 60,
	overwrite = 999,
}

#endregion


#region Exported variables

@export_category("General")
@export var TYPE : Player.ActionType
@export var PRIORITY : int = 0
@export var ANIMATION_NAME : String
@export var ROTATION_TRACKING_SPEED : float = 10

@export_category("Combat")
@export var ENERGY_COST : float = 0
# @export var QUEUEABLE : bool = false # For what?

#endregion


#region Scene members

var player : Player
var physics : PlayerPhysics
var manager : PlayerActionManager
var combatManager : PlayerCombatManager
var cameraManager : PlayerCameraManager
var actionData : PlayerActionData
var resources : PlayerResources
var animationPlayer : AnimationPlayer

#endregion


#region Member variables

var progress : float
var DURATION : float

var queue : Player.ActionType = Player.ActionType.none # Queued action, used for combos and buffering, not guaranteed to happen next
var next : Player.ActionType = Player.ActionType.none # Guaranteed next action after the current one has ended

#endregion


#region Public funcitons

func init(
	player_ : Player, \
	manager_ : PlayerActionManager, \
	physics_ : PlayerPhysics, \
	combatManager_ : PlayerCombatManager, \
	cameraManager_ : PlayerCameraManager, \
	actionData_ : PlayerActionData, \
	resources_ : PlayerResources, \
	animationPlayer_ : AnimationPlayer, \
) -> void:
	player = player_
	manager = manager_
	physics = physics_
	combatManager = combatManager_
	cameraManager = cameraManager_
	actionData = actionData_
	resources = resources_
	animationPlayer = animationPlayer_


# This is called on every frame when the action is enabled
func tick(input : PlayerInputManager.Data, delta : float) -> void:
	progress += delta

	processDirection(input, delta)
	
	tickImpl(input, delta)


# This is executed on action enter
func enter() -> void:
	resources.payAction(self)
	
	if combatManager.isNextComboAction(TYPE):
		ANIMATION_NAME = combatManager.registerComboAction(TYPE)
		
	animationPlayer.play(ANIMATION_NAME)
	
	enterImpl()

# This is executed on action exit and resets the action to prepare it for the next time it's activated
func exit() -> void:
	exitImpl()
	
	progress = 0
	
	queue = Player.ActionType.none
	next = Player.ActionType.none

# This checks if the current action should continue or if not, the action to transition to based on all inputs
func nextAction(input : PlayerInputManager.Data) -> Player.ActionType:
	if actionData.acceptsQueue(ANIMATION_NAME, progress) and input.actions.size() == 0: # Set the queued action
		checkAndSetQueue(input)

	if not actionData.transitionable(ANIMATION_NAME, progress):
		return Player.ActionType.none
	
	if queue != Player.ActionType.none: # If a transition can occur and the queue is set, push the queue as the next action
		checkAndSetNext(queue)

	if next == Player.ActionType.none: # If all above cases do not trigger a transition, just check for the input causing the highest priority action
		next = highestPriorityAction(input)
	
	nextStateImpl(input)

	return next

#endregion


#region Private functions

# Check if a queueable move is present, can be queued with the current action and set it if these are the case
func checkAndSetQueue(input : PlayerInputManager.Data) -> void:
	queue = input.actions[0]

	# Checks if a pause has been detected and a pause is part of the combo
	if actionData.comboPause(ANIMATION_NAME, progress):
		if combatManager.isNextComboAction(Player.ActionType.idle):
			combatManager.registerComboAction(Player.ActionType.idle)
		# else: # This can be uncommented and the function below implemented to add punishment for button mashing
		#	combatManager.breakCombo()

# Check if the next action can be set (i.e. has a higher priority than the current next action)
func checkAndSetNext(actionType : Player.ActionType) -> void:
	if next != Player.ActionType.none: # If it were none, just set the action type
		var action := manager.actions[actionType]
		if !resources.canAffordAction(action) or manager.actions[next].PRIORITY < action.PRIORITY: # Check for the priorities of the potential next actions
			return
	
	next = actionType


# Gets the highest priority action from the current input, given it has a higher pritority than the current one
func highestPriorityAction(input : PlayerInputManager.Data) -> Player.ActionType:
	# Go through all higher priority actions and immediately return them if possible as they can cancel the current action
	for actionType in input.actions:
		var action := manager.actions[actionType]
		
		# If both animations have the same type, just ignore it and break
		# If the current action is not yet finished and the other has the same priority, don't play the ANIMATION_NAME
		if action.TYPE == TYPE or action.PRIORITY <= PRIORITY and progress < DURATION:
			break # We can directly break instead of continuing, since the actions are sorted
		
		if resources.canAffordAction(action):
			return actionType
	
	return Player.ActionType.none


# If enabled, this will influence the direction the player faces using the direction of the input package
func processDirection(input : PlayerInputManager.Data, delta : float) -> void:
	if actionData.trackDirection(ANIMATION_NAME, progress):
		player.rotate_y(clampf( \
			player.basis.z.signed_angle_to(Vector3(input.direction.x, 0, input.direction.y), Vector3.UP), \
			-ROTATION_TRACKING_SPEED * delta, ROTATION_TRACKING_SPEED * delta))

#endregion


#region Implementation functions

func tickImpl(_input : PlayerInputManager.Data, _delta : float) -> void:
	pass

func enterImpl() -> void:
	pass

# Modify the next variable in this function
func nextStateImpl(_input : PlayerInputManager.Data):
	pass

func exitImpl() -> void:
	pass

#endregion
