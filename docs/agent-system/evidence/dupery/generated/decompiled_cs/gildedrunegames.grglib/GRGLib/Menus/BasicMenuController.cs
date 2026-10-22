using System.Collections;
using GRGLib.Coroutines;
using UnityEngine;

namespace GRGLib.Menus;

[AddComponentMenu("GRGLib/Menu/Basic Menu Controller")]
public class BasicMenuController : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	protected CanvasGroup menu_group;

	[Header("Settings")]
	[SerializeField]
	private bool start_open;

	[SerializeField]
	private bool toggle_gameobject = true;

	protected CoroutineRunner menuing_anim;

	private MenuState m_current_state = (MenuState)(-9);

	public MenuState current_state
	{
		get
		{
			return m_current_state;
		}
		protected set
		{
			if (m_current_state != value)
			{
				m_current_state = value;
				onChangedState();
			}
		}
	}

	public bool is_open => current_state == MenuState.OPEN;

	public bool is_closed => current_state == MenuState.CLOSED;

	public bool transitioning
	{
		get
		{
			if (current_state != MenuState.CLOSING)
			{
				return current_state == MenuState.OPENING;
			}
			return true;
		}
	}

	public bool is_unfocused => current_state == MenuState.UNFOCUS_OPEN;

	protected virtual void Awake()
	{
		menuing_anim = new CoroutineRunner(this);
		current_state = (start_open ? MenuState.OPEN : MenuState.CLOSED);
	}

	public void openMenu()
	{
		if (!is_open && !is_unfocused && current_state != MenuState.OPENING)
		{
			current_state = MenuState.OPENING;
			menuing_anim.run(openingMenuAnimation().addCallback(delegate
			{
				current_state = MenuState.OPEN;
			}));
		}
	}

	public void closeMenu()
	{
		if (!is_closed && current_state != MenuState.CLOSING)
		{
			current_state = MenuState.CLOSING;
			menuing_anim.run(closingMenuAnimation().addCallback(delegate
			{
				current_state = MenuState.CLOSED;
			}));
		}
	}

	public void toggleMenu()
	{
		if (is_open || current_state == MenuState.OPENING)
		{
			closeMenu();
		}
		else
		{
			openMenu();
		}
	}

	private void onChangedState()
	{
		switch (current_state)
		{
		case MenuState.CLOSING:
			onMenuClosing();
			break;
		case MenuState.CLOSED:
			onMenuClosed();
			break;
		case MenuState.OPENING:
			onMenuOpening();
			break;
		case MenuState.OPEN:
			onMenuOpen();
			break;
		case MenuState.UNFOCUS_OPEN:
			onUnfocus();
			break;
		}
	}

	protected virtual void onMenuClosing()
	{
		menu_group.interactable = false;
	}

	protected virtual void onMenuClosed()
	{
		menu_group.interactable = false;
		menu_group.blocksRaycasts = false;
		if (toggle_gameobject)
		{
			base.gameObject.SetActive(value: false);
		}
	}

	protected virtual void onMenuOpening()
	{
		if (toggle_gameobject)
		{
			base.gameObject.SetActive(value: true);
		}
		menu_group.blocksRaycasts = true;
	}

	protected virtual void onMenuOpen()
	{
		menu_group.interactable = true;
		menu_group.blocksRaycasts = true;
	}

	protected virtual void onUnfocus()
	{
		menu_group.interactable = false;
	}

	protected virtual IEnumerator openingMenuAnimation()
	{
		return menu_group.fadeRealTime(1f, 0.35f, CoroutineExtensions.easeInOutFunc);
	}

	protected virtual IEnumerator closingMenuAnimation()
	{
		return menu_group.fadeRealTime(0f, 0.35f, CoroutineExtensions.easeInOutFunc);
	}
}
