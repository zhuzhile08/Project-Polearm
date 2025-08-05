extends RefCounted
class_name PlayerComboAction

# Only set to a valid combo type if the action is the last in a chain
var FINAL_COMBO_TYPE : Player.ComboType = Player.ComboType.none
var DATA : PlayerCombo.ActionData

var tree : Dictionary = { }

func _init(data : PlayerCombo.ActionData = PlayerCombo.ActionData.new()) -> void:
	self.DATA = data
