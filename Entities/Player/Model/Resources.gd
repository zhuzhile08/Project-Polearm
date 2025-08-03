extends Node
class_name PlayerResources

# Configurable variables

@export_category("States")

@export var godMode : bool = false

@export var invincibility : bool = false
@export var slowMotion : bool = false # 天机

@export var sonOfHeaven : bool = false

@export var unlockedActions : Array[Player.ActionType]


@export_category("Resources")

@export var health : float = 1000
@export var maxHealth : float = 1000

@export var energy : float = 0 # 灵气
@export var maxEnergy : float = 1000

@export var flow : float = 0 # 道势
@export var maxFlow : float = 1000

@export var spiritOrbs : int = 0 # 魄
@export var healthUpgrades : int = 0 # 3 for a full upgrade

# @export var inventory : Array[Items]


@export_category("Modifiers")

# @export var witchModeTime : float # Duration of witch mode

@export var BASE_FLOW_DECREASE_RATE : float
@export var flowModifier : float = 1

@export var FLOW_CURVE : Curve


# Member variables

@onready var model := $".." as PlayerModel


# Member functions

func update(delta: float) -> void:
	looseFlow(delta * BASE_FLOW_DECREASE_RATE * flowModifier)


# Health functionality

func gainHealth(amount : float) -> void:
	health = min(health + amount, maxHealth)

func looseHealth(amount : float) -> void:
	health = max(health - amount, 0)
	
	if health == 0:
		model.forceSwitch(Player.ActionType.death)


# Flow functionality

func gainFlow(amount : float) -> void:
	flow = min(flow + amount, maxFlow)

func looseFlow(amount : float) -> void:
	flow = max(flow - amount, 0)

func flowToState() -> Player.FlowState:
	return Player.FlowState.values()[floori(FLOW_CURVE.sample(clampf(flow, 0, FLOW_CURVE.max_value + 0.5)))]


# Energy functionality

func gainEnergy(amount : float) -> void:
	energy = min(energy + amount, maxEnergy)

func looseEnergy(amount : float) -> void:
	energy = max(energy - amount, 0)


# Action functionality

func canAffordAction(action : PlayerAction) -> bool:
	if action.ENERGY_COST <= energy:
		return true
	return false

func payAction(action : PlayerAction) -> void:
	energy -= action.ENERGY_COST
