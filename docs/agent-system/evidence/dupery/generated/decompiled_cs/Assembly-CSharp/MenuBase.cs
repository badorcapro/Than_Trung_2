using System;
using System.Collections.Generic;
using Audio;
using GRGLib.Coroutines;
using GRGLib.Extensions.Unity;
using GRGLib.Menus;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class MenuBase : SelectablesMenuController
{
	private Dictionary<Transform, CoroutineRunner> jiggle_runners = new Dictionary<Transform, CoroutineRunner>();

	protected Selectable last_selected;

	private bool forced_open;

	protected bool should_refocus_on_confirmation_close = true;

	protected virtual Selectable select_device_change => initial_button;

	protected override bool UsingSelectables
	{
		get
		{
			if (!base.UsingSelectables)
			{
				if (input != null)
				{
					return input.getInputType() == InputType.G_SWITCH;
				}
				return false;
			}
			return true;
		}
	}

	protected override void Awake()
	{
		base.Awake();
		if (forced_open && base.current_state != MenuState.OPEN)
		{
			forceOpenImmidiate(_check_awake: false);
		}
	}

	protected void openConfirmationMenu(ConfirmationMenu _menu, string _text, Action _confirm, Action _cancel)
	{
		_menu.setUp(_text, _confirm, _cancel);
		openNewMenuTemp(_menu);
	}

	public void setPlayerInput(PlayerInput _input)
	{
		input = _input;
	}

	public void openNewMenuTemp(MenuController _menu)
	{
		unfocusMenu();
		_menu.openMenu(delegate
		{
			if (should_refocus_on_confirmation_close)
			{
				refocusMenu();
			}
		});
	}

	protected void openQuadConfirmationMenu(QuadConfimrationMenu _menu, string _text, Action _a_callback, string _a_text, Action _b_callback, string _b_text, Action _c_callback, string _c_text, Action _d_callback, string _d_text)
	{
		_menu.setUp(_text, _a_callback, _a_text, _b_callback, _b_text, _c_callback, _c_text, _d_callback, _d_text);
		openNewMenu(_menu);
	}

	protected override void refocusMenu()
	{
		base.refocusMenu();
		if (GameHandler.instance.using_gamepad)
		{
			if (last_selected != null)
			{
				last_selected.Select();
			}
			else
			{
				initial_button.Select();
			}
		}
	}

	public void jiggleButton(Transform _transform)
	{
		if (!jiggle_runners.ContainsKey(_transform))
		{
			jiggle_runners[_transform] = new CoroutineRunner(this);
		}
		jiggle_runners[_transform].run(_transform.jiggle());
	}

	public virtual void onDeviceChange(PlayerInput _input)
	{
		if ((EventSystem.current == null || !EventSystem.current.alreadySelecting) && _input.isUsingGamepad() && base.is_open)
		{
			select_device_change.Select();
		}
		GameHandler.instance.setControlScheme(_input.currentControlScheme);
	}

	public void playButtonPressSfx()
	{
		AudioHandler.Sfx.playSfx(Sfx.TEST_BUTTON);
	}

	public void setLastSelected(Selectable _selectable)
	{
		last_selected = _selectable;
	}

	public void forceOpenImmidiate(bool _check_awake = true)
	{
		menu_group.putOn();
		menu_group.interactable = true;
		menu_group.blocksRaycasts = true;
		base.current_state = MenuState.OPEN;
		forced_open = _check_awake;
		base.gameObject.SetActive(value: true);
	}

	public void forceCloseImmidiate()
	{
		menu_group.putOn(_on: false);
		menu_group.interactable = false;
		menu_group.blocksRaycasts = false;
		base.current_state = MenuState.CLOSED;
		base.gameObject.SetActive(value: false);
	}
}
