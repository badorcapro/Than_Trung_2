using System;
using System.Collections.Generic;
using UnityEngine.InputSystem;

namespace ControllerSupport;

public class AdvancedInputHandler : BaseInputHandler
{
	protected Dictionary<ControllerActions, Dictionary<string, Action<InputAction.CallbackContext>>> controller_actions = new Dictionary<ControllerActions, Dictionary<string, Action<InputAction.CallbackContext>>>();

	protected Dictionary<string, Action<PlayerInput>> on_device_change = new Dictionary<string, Action<PlayerInput>>();

	public void addDeviceChangeCallback(string _key, Action<PlayerInput> _on_device_change)
	{
		on_device_change[_key] = _on_device_change;
	}

	public void removeDeviceChangeCallback(string _key)
	{
		on_device_change.Remove(_key);
	}

	public void addActionCallback(ControllerActions _action, string _key, Action<InputAction.CallbackContext> _callback)
	{
		if (!controller_actions.ContainsKey(_action))
		{
			controller_actions[_action] = new Dictionary<string, Action<InputAction.CallbackContext>>();
		}
		controller_actions[_action][_key] = _callback;
	}

	public void removeActionCallback(ControllerActions _action, string _key)
	{
		if (controller_actions.ContainsKey(_action) && controller_actions[_action].ContainsKey(_key))
		{
			controller_actions[_action].Remove(_key);
			if (controller_actions[_action].Count == 0)
			{
				controller_actions.Remove(_action);
			}
		}
	}

	protected void checkSceneActions(ControllerActions _action, InputAction.CallbackContext _context)
	{
		if (!controller_actions.ContainsKey(_action))
		{
			return;
		}
		foreach (KeyValuePair<string, Action<InputAction.CallbackContext>> item in controller_actions[_action])
		{
			item.Value(_context);
		}
	}

	protected override void onChangeToGamepad(PlayerInput _input)
	{
		foreach (KeyValuePair<string, Action<PlayerInput>> item in on_device_change)
		{
			item.Value(_input);
		}
	}

	protected override void onChangeToKBM(PlayerInput _input)
	{
		foreach (KeyValuePair<string, Action<PlayerInput>> item in on_device_change)
		{
			item.Value(_input);
		}
	}

	protected override void onSouthButton(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.SOUTH, _context);
	}

	protected override void onEastButton(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.EAST, _context);
	}

	protected override void onWestButton(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.WEST, _context);
	}

	protected override void onNorthButton(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.NORTH, _context);
	}

	protected override void onWestShoulder(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.SHOULDER_WEST, _context);
	}

	protected override void onEastShoulder(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.SHOULDER_EAST, _context);
	}

	protected override void onWestTrigger(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.TRIGGER_WEST, _context);
	}

	protected override void onEastTrigger(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.TRIGGER_EAST, _context);
	}

	protected override void onRightJoystick(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.RIGHT_JOYSTICK, _context);
	}

	protected override void onSelectButton(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.SELECT, _context);
	}

	protected override void onSpace(InputAction.CallbackContext _context)
	{
		checkSceneActions(ControllerActions.K_SPACE, _context);
	}
}
