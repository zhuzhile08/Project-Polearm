extends Node
class_name PlayerCombatManager


#region Exported variables

@export_group("Combat config")
@export var PREVIOUS_COMBO_COUNT : int

@export_group("Combat data")
@export var unlockedCombos : Array[PlayerCombo]

#endregion


#region Scene members

@export_group("Scene members")
@export var resources : PlayerResources

#endregion


#region Member variables

@onready var comboTree : PlayerComboAction = PlayerComboAction.new()
@onready var currentComboAction : PlayerComboAction = comboTree

var previousCombos : Array[Player.ComboType]

#endregion


#region Built-in functions

func _ready() -> void:
	assert(resources != null, "PlayerCombatManager._ready(): Resource container not assigned!")

	for combo in unlockedCombos:
		unlockCombo(combo)

#endregion


#region Public functions

func tick(_delta : float) -> void:
	pass


func unlockCombo(combo : PlayerCombo) -> void:
	var combos := comboTree
	for action in combo.ACTIONS:
		if not combos.tree.has(action.TYPE):
			combos.tree[action.TYPE] = PlayerComboAction.new(action)
		combos = combos.tree[action.TYPE]
	combos.FINAL_COMBO_TYPE = combo.TYPE


func resetActiveCombo() -> void:
	currentComboAction = comboTree

func hasActiveCombo() -> bool:
	if currentComboAction.TYPE == Player.ActionType.none:
		return false
	return true

func isNextComboAction(action : Player.ActionType) -> bool:
	if currentComboAction.tree.has(action):
		return true
	return false


# Assumes the action has been checked and is valid
func registerComboAction(action : Player.ActionType) -> String:
	assert(isNextComboAction(action), "PlayerCombatManager.registerComboAction(): Action is not next in chain, please check before calling the function!")
	
	var current = currentComboAction.tree[action] # The type of this variable will be unsure depending on the position in the tree
	
	if current.TYPE != Player.ComboType.none:
		if previousCombos.size() == PREVIOUS_COMBO_COUNT:
			previousCombos.pop_front()
		previousCombos.append(current.TYPE)
		
		resetActiveCombo()
	else:
		currentComboAction = current # Somewhere here, check for collision or recieve the check to pay the action
	
	return current.ANIMATION

# Returns 0 if the combo wasn't used previously
func comboPreviousUse(combo : Player.ComboType) -> int:
	for x in range(1, previousCombos.size() + 1):
		if previousCombos[-x] == combo:
			return x + 1
	return 0

#endregion
