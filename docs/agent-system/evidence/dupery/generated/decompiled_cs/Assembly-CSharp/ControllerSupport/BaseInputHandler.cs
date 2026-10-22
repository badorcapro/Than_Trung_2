using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace ControllerSupport;

public class BaseInputHandler : MonoBehaviour
{
	[SerializeField]
	protected PlayerInput player_input;

	[SerializeField]
	protected PauseMenu pause_menu;

	protected CoroutineRunner selectable_check_runner;

	protected Maybe<Selectable> last_selectable = new Maybe<Selectable>();

	protected virtual void Awake()
	{
		if (selectable_check_runner == null)
		{
			selectable_check_runner = new CoroutineRunner(this);
		}
	}

	protected virtual void Start()
	{
		if (GameHandler.instance.using_gamepad)
		{
			selectable_check_runner.runIfNot(checkForLastSelectable());
		}
	}

	private IEnumerator checkForLastSelectable()
	{
		GameObject last_selected = null;
		while (!pause_menu.is_open && !pause_menu.transitioning && !pause_menu.is_unfocused)
		{
			if (!isAnythingSelected())
			{
				if (!player_input.isUsingGamepad())
				{
					break;
				}
				trySelectSomething();
			}
			else if (EventSystem.current.currentSelectedGameObject != last_selected)
			{
				last_selected = EventSystem.current.currentSelectedGameObject;
				last_selectable = last_selected.GetComponent<Selectable>().maybe();
			}
			yield return null;
		}
	}

	public bool isAnythingSelected()
	{
		return EventSystem.current.currentSelectedGameObject != null;
	}

	public void logSelectedObject()
	{
		Debug.Log(isAnythingSelected() ? EventSystem.current.currentSelectedGameObject.name : "null");
	}

	public virtual void onUnpause()
	{
		Debug.Log("Controller Unpause");
		if (last_selectable.is_some)
		{
			last_selectable.value.Select();
		}
		selectable_check_runner.run(checkForLastSelectable());
	}

	public virtual bool trySelectSomething()
	{
		if (last_selectable.is_some)
		{
			if (last_selectable.value == null)
			{
				last_selectable = new Maybe<Selectable>();
				return false;
			}
			last_selectable.value.Select();
			return true;
		}
		return false;
	}

	public void onDeviceChange(PlayerInput _input)
	{
		if (selectable_check_runner == null)
		{
			selectable_check_runner = new CoroutineRunner(this);
		}
		GameHandler.instance.setControlScheme(_input.currentControlScheme);
		if (_input.isUsingGamepad())
		{
			selectable_check_runner.runIfNot(checkForLastSelectable());
			onChangeToGamepad(_input);
		}
		else
		{
			selectable_check_runner.stop();
			onChangeToKBM(_input);
		}
	}

	protected virtual void onChangeToGamepad(PlayerInput _input)
	{
	}

	protected virtual void onChangeToKBM(PlayerInput _input)
	{
	}

	public void onControllerSouthButton(InputAction.CallbackContext _context)
	{
		if (!pause_menu.is_open)
		{
			onSouthButton(_context);
		}
	}

	protected virtual void onSouthButton(InputAction.CallbackContext _context)
	{
	}

	public void onControllerEastButton(InputAction.CallbackContext _context)
	{
		if (pause_menu.is_open)
		{
			if (_context.canceled)
			{
				pause_menu.onStartButton(onUnpause);
			}
		}
		else
		{
			onEastButton(_context);
		}
	}

	protected virtual void onEastButton(InputAction.CallbackContext _context)
	{
	}

	public void onControllerWestButton(InputAction.CallbackContext _context)
	{
		if (!pause_menu.is_open)
		{
			onWestButton(_context);
		}
	}

	protected virtual void onWestButton(InputAction.CallbackContext _context)
	{
	}

	public void onControllerNorthButton(InputAction.CallbackContext _context)
	{
		if (!pause_menu.is_open)
		{
			onNorthButton(_context);
		}
	}

	protected virtual void onNorthButton(InputAction.CallbackContext _context)
	{
	}

	public void onControllerWestShoulder(InputAction.CallbackContext _context)
	{
		if (!pause_menu.is_open)
		{
			onWestShoulder(_context);
		}
	}

	protected virtual void onWestShoulder(InputAction.CallbackContext _context)
	{
	}

	public void onControllerEastShoulder(InputAction.CallbackContext _context)
	{
		if (!pause_menu.is_open)
		{
			onEastShoulder(_context);
		}
	}

	protected virtual void onEastShoulder(InputAction.CallbackContext _context)
	{
	}

	public void onControllerWestTrigger(InputAction.CallbackContext _context)
	{
		if (!pause_menu.is_open)
		{
			onWestTrigger(_context);
		}
	}

	protected virtual void onWestTrigger(InputAction.CallbackContext _context)
	{
	}

	public void onControllerEastTrigger(InputAction.CallbackContext _context)
	{
		if (!pause_menu.is_open)
		{
			onEastTrigger(_context);
		}
	}

	protected virtual void onEastTrigger(InputAction.CallbackContext _context)
	{
	}

	public void onControllerRightJoystick(InputAction.CallbackContext _context)
	{
		if (!pause_menu.is_open)
		{
			onRightJoystick(_context);
		}
	}

	protected virtual void onRightJoystick(InputAction.CallbackContext _context)
	{
	}

	public void onControllerLeftJoystick(InputAction.CallbackContext _context)
	{
		if (!pause_menu.is_open)
		{
			onLeftJoystick(_context);
		}
	}

	protected virtual void onLeftJoystick(InputAction.CallbackContext _context)
	{
	}

	public void onControllerDpad(InputAction.CallbackContext _context)
	{
		if (!pause_menu.is_open)
		{
			onDpad(_context);
		}
	}

	protected virtual void onDpad(InputAction.CallbackContext _context)
	{
	}

	public void onStartButton(InputAction.CallbackContext _context)
	{
		if (_context.canceled)
		{
			pause_menu.onStartButton(onUnpause);
		}
	}

	public void onControllerSelectButton(InputAction.CallbackContext _context)
	{
		if (!pause_menu.is_open)
		{
			onSelectButton(_context);
		}
	}

	protected virtual void onSelectButton(InputAction.CallbackContext _context)
	{
	}

	public void onSpaceButton(InputAction.CallbackContext _context)
	{
		if (!pause_menu.is_open)
		{
			onSpace(_context);
		}
	}

	protected virtual void onSpace(InputAction.CallbackContext _context)
	{
	}

	public void onEscapeButton(InputAction.CallbackContext _context)
	{
		if (pause_menu.is_open)
		{
			if (_context.canceled)
			{
				pause_menu.onStartButton(delegate
				{
				});
			}
		}
		else
		{
			onEscape(_context);
		}
	}

	protected virtual void onEscape(InputAction.CallbackContext _context)
	{
		if (_context.canceled)
		{
			pause_menu.onStartButton(delegate
			{
			});
		}
	}
}
