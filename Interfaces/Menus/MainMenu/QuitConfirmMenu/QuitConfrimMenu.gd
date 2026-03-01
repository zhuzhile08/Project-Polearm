extends InterfaceState


#region Export variables

@export var BACK_MENU : Type

#endregion


#region Implementation functions

func type() -> Type:
	return Type.quitConfirmMenu

func nextMenu(inputs : ISMInputManager.Data) -> Type:
	if inputs.cancel:
		return BACK_MENU
	return Type.none


#endregion
