extends Control

var pressToStart = false;

func _ready() -> void:
	for child in get_children():
		child.hide()
		$StartMenu.show()
		
	# Connect buttons
	connectHoverAndFocus(get_children())
	child_entered_tree.connect(onChildAdded)

func onChildAdded(node: Node):
	if node is Button:
		node.mouse_entered.connect(onButtonHover.bind(node))

func connectHoverAndFocus(nodes: Array):
	for node in nodes:
		if node is Button:
			node.mouse_entered.connect(onButtonHover.bind(node))
		connectHoverAndFocus(node.get_children())

func onButtonHover(button: Button):
	button.grab_focus()
