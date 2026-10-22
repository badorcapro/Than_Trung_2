using System;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using UnityEngine;

namespace GRGLib.Menus;

[AddComponentMenu("GRGLib/Menu/Menu Controller")]
public class MenuController : BasicMenuController
{
	[SerializeField]
	private bool close_on_new;

	protected Maybe<Action> on_close_callback = new Maybe<Action>();

	protected bool callback_is_unique = true;

	protected bool new_menu_opened;

	public void openMenu(Action _on_close_callback, bool _is_unique = true)
	{
		on_close_callback = _on_close_callback.maybe();
		callback_is_unique = _is_unique;
		openMenu();
	}

	public void openNewMenu(MenuController _menu)
	{
		unfocusMenu();
		_menu.openMenu(refocusMenu);
	}

	protected virtual void unfocusMenu()
	{
		if (close_on_new)
		{
			menuing_anim.run(closingMenuAnimation());
		}
		base.current_state = MenuState.UNFOCUS_OPEN;
	}

	protected virtual void refocusMenu()
	{
		if (close_on_new)
		{
			menuing_anim.run(openingMenuAnimation().addCallback(delegate
			{
				base.current_state = MenuState.OPEN;
			}));
		}
		else
		{
			base.current_state = MenuState.OPEN;
		}
	}

	protected override void onMenuClosed()
	{
		base.onMenuClosed();
		if (on_close_callback.is_some)
		{
			on_close_callback.value();
			if (callback_is_unique)
			{
				on_close_callback = new Maybe<Action>();
			}
		}
	}

	public void quitGame()
	{
		Application.Quit();
	}
}
