extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# --- Maps inputs with multiple usecases to intentions ---
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		sendIntention(SignalBus.Intent.CANCELORPAUSE)

# --- Intention Communication ---
func sendIntention(intention: SignalBus.Intent) -> void:
	SignalBus.intentionReceived.emit(intention)
