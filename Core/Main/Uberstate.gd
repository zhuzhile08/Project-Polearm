extends Node
class_name Uberstate


#region Enums

enum Type {
	none,

	boot,
	mainMenu,
	game,
	loading,
	pause,
}

#endregion


#region Exported Variables

@export var TYPE : Type

#endregion
