extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# --- Maps Inputs with multiple usecases to intentions ---
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		sendIntention("cancelOrPause")

# --- Intention Communication ---
func sendIntention(intention: String) -> void:
	SignalBus.intention.emit(intention)
