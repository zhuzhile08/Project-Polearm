extends Node
class_name PlayerCombatManager

# Configurable variables

@export var PREVIOUS_COMBO_COUNT : int


# Member variables

@onready var resources : PlayerResources

var combos : Dictionary[Player.ComboType, PlayerCombo]
var comboTree : Dictionary[Player.ActionType, Dictionary]

var currentCombo : Dictionary
var previousCombos : Array[Player.ComboType]


# Member functions

func init() -> void:
	for child in get_children():
		if child is PlayerCombo:
			unlockCombo(child as PlayerCombo)

func update(delta : float) -> void:
	pass


# Combo functions

func unlockCombo(combo : PlayerCombo) -> void:
	var tree = comboTree
	for action in combo.ACTIONS:
		if !tree.has(action):
			tree[action] = { }
		tree = tree[action]
	tree[Player.ActionType.none] = combo.TYPE
	
	combos[combo.TYPE] = combo

func clearCurrentCombo() -> void:
	currentCombo = comboTree

func isCurrentComboAction(action : Player.ActionType) -> bool:
	if currentCombo.has(action):
		return true
	return false

func registerComboAction(action : Player.ActionType) -> String:
	var current = comboTree[action]
	
	if current is Player.ComboType:
		if previousCombos.size() == PREVIOUS_COMBO_COUNT:
			previousCombos.pop_front()
		previousCombos.append(current)
	else:
		currentCombo = current
	
	# Determine the animation name and return it
	return ""

# Returns 0 if the combo wasn't used previously
func comboPreviousUse(combo : Player.ComboType) -> int:
	for x in range(1, previousCombos.size() + 1):
		if previousCombos[-x] == combo:
			return x + 1
	return 0
