extends Node

func _ready() -> void:
	# This ensures the script keeps running even when get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	# Global Input Handling
	if Input.is_action_just_pressed("ui_cancel"): # Usually Escape
		sendIntention("cancelOrPause")

func sendIntention(intention: String) -> void:
	SignalBus.intention.emit(intention)
