extends Control


#region Enums

enum Type { 
	none,
	mainMenu,
	options,
	pause,
	gameOptions,
	videoOptions,
	audioOptions,
	controllerOptions,
	keyboardOptions,
}

#endregion


#region Member functions

func enter():
	show()

func exit():
	hide()

func nextMenu(inputs: MainInputManager.Data):
	pass

func showMenu():
	show()

func hideMenu():
	hide()
	
#endregion
