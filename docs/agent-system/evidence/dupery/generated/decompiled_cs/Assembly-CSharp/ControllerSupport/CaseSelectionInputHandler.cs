using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace ControllerSupport;

public class CaseSelectionInputHandler : AdvancedInputHandler
{
	protected List<Action<PlayerInput>> on_device_gamepad = new List<Action<PlayerInput>>();

	protected List<Action<PlayerInput>> on_device_keyboard = new List<Action<PlayerInput>>();

	public Maybe<Selectable> backup_selectable = new Maybe<Selectable>();

	public PlayerInput getPlayerInput()
	{
		return player_input;
	}

	public void setBackupSelectable(Selectable _selectable)
	{
		backup_selectable = _selectable.maybe();
	}

	public override bool trySelectSomething()
	{
		if (base.trySelectSomething())
		{
			return true;
		}
		if (backup_selectable.is_some)
		{
			backup_selectable.value.Select();
			return true;
		}
		return false;
	}

	protected override void onSouthButton(InputAction.CallbackContext _context)
	{
		base.onSouthButton(_context);
	}
}
