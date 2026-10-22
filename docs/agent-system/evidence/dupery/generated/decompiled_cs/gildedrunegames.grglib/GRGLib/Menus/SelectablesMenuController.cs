using GRGLib.Input;
using GRGLib.Maybe;
using GRGLib.PropertyDrawers;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace GRGLib.Menus;

[AddComponentMenu("GRGLib/Menu/Menu Controller (Selectables)")]
public class SelectablesMenuController : MenuController, ISelectables
{
	[Space]
	[Header("Selectables")]
	[SerializeField]
	protected bool using_grg_input;

	[SerializeField]
	[ConditionalField("using_grg_input", false, new object[] { false })]
	protected PlayerInput input;

	[SerializeField]
	protected Selectable initial_button;

	[SerializeField]
	protected bool always_select;

	[SerializeField]
	protected bool close_on_cancel = true;

	protected Maybe<Selectable> last_selectable = new Maybe<Selectable>();

	protected virtual bool UsingSelectables
	{
		get
		{
			if (!always_select)
			{
				if (!using_grg_input)
				{
					return input.usingController();
				}
				return GRGInputHandler.instance.useSelectables();
			}
			return true;
		}
	}

	protected virtual bool SetInitialButton
	{
		get
		{
			if (initial_button != null)
			{
				return UsingSelectables;
			}
			return false;
		}
	}

	protected override void Awake()
	{
		base.Awake();
		if (using_grg_input)
		{
			GRGInputHandler.instance.addSelectable(this);
		}
		if (base.is_open && SetInitialButton)
		{
			initial_button.Select();
		}
	}

	protected override void onMenuOpen()
	{
		base.onMenuOpen();
		if (last_selectable.is_some && UsingSelectables)
		{
			last_selectable.value.Select();
			last_selectable = new Maybe<Selectable>();
		}
		else if (SetInitialButton)
		{
			initial_button.Select();
		}
	}

	protected override void unfocusMenu()
	{
		base.unfocusMenu();
		if (UsingSelectables && EventSystem.current.currentSelectedGameObject != null)
		{
			Selectable component = EventSystem.current.currentSelectedGameObject.GetComponent<Selectable>();
			if (component != null)
			{
				last_selectable = component.maybe();
			}
		}
	}

	protected override void refocusMenu()
	{
		base.refocusMenu();
		if (base.is_open && UsingSelectables && last_selectable.is_some)
		{
			last_selectable.value.Select();
			last_selectable = new Maybe<Selectable>();
		}
	}

	public void selectInitialButton()
	{
		if (base.is_open && SetInitialButton)
		{
			initial_button.Select();
		}
	}

	public void onControlsChange(string _controls)
	{
		if (base.is_open && UsingSelectables && !(EventSystem.current.currentSelectedGameObject != null))
		{
			initial_button.Select();
		}
	}

	public virtual void Cancel()
	{
		if ((base.is_open || base.current_state == MenuState.OPENING) && !new_menu_opened && close_on_cancel)
		{
			closeMenu();
		}
	}
}
