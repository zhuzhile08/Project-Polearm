extends Resource
class_name PlayerCombo


class ActionData extends Resource:
	@export var TYPE : Player.ActionType
	@export var ANIMATION : String
	@export var DAMAGE : int
	@export var FLOW : int


@export var TYPE : Player.ComboType
@export var ACTIONS : Array[ActionData]
