using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using UnityEngine;

namespace GRGLib.Menus;

public abstract class HoverMenuBase : MonoBehaviour
{
	private MenuState m_current_state = (MenuState)(-9);

	protected HashSet<MonoBehaviour> want_open = new HashSet<MonoBehaviour>();

	protected CoroutineRunner menuing_runner;

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
		menuing_runner = new CoroutineRunner(this);
	}

	public void tryOpen(MonoBehaviour _opener)
	{
		want_open.Add(_opener);
		checkState();
	}

	public void tryClose(MonoBehaviour _closer)
	{
		want_open.Remove(_closer);
		checkState();
	}

	public bool isOpenWith(MonoBehaviour _mono)
	{
		if (want_open.Count > 0)
		{
			return want_open.Last() == _mono;
		}
		return false;
	}

	protected void checkState()
	{
		want_open.RemoveWhere((MonoBehaviour _m) => _m == null);
		if (want_open.Count > 0)
		{
			open();
		}
		else
		{
			close();
		}
	}

	public void forceCloseAndReset()
	{
		want_open.Clear();
		close();
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
	}

	protected virtual void onMenuClosed()
	{
	}

	protected virtual void onMenuOpening()
	{
	}

	protected virtual void onMenuOpen()
	{
	}

	protected virtual void onUnfocus()
	{
	}

	protected void open()
	{
		if (!is_open && !is_unfocused && current_state != MenuState.OPENING)
		{
			current_state = MenuState.OPENING;
			menuing_runner.run(openingAnimation().addCallback(delegate
			{
				current_state = MenuState.OPEN;
			}));
		}
	}

	protected abstract IEnumerator openingAnimation();

	protected void close()
	{
		if (!is_closed && current_state != MenuState.CLOSING)
		{
			current_state = MenuState.CLOSING;
			menuing_runner.run(closingAnimation().addCallback(delegate
			{
				current_state = MenuState.CLOSED;
			}));
		}
	}

	protected abstract IEnumerator closingAnimation();
}
