using System;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using GRGLib.PropertyDrawers;
using UnityEngine;
using UnityEngine.EventSystems;

namespace GRGLib.UI;

[AddComponentMenu("GRGLib/UI/Tab")]
public class Tab : AdvancedButton
{
	public enum TabState
	{
		CLOSED,
		OPEN,
		HOVERING,
		HIDDEN
	}

	[Header("Tab Settings")]
	[SerializeField]
	private TabState starting_state;

	[SerializeField]
	private bool lock_starting_state;

	[SerializeField]
	private bool open_on_click;

	[SerializeField]
	[ConditionalField("open_on_click")]
	private bool lock_on_click = true;

	[SerializeField]
	private Vector2 hover_pos;

	[SerializeField]
	private Vector2 selected_pos;

	[SerializeField]
	private Vector2 closed_pos;

	[SerializeField]
	private Vector2 hidden_pos;

	[SerializeField]
	private float state_change_duration = 0.4f;

	protected Maybe<Coroutine> moving_coroutine = new Maybe<Coroutine>();

	public RectTransform rect_trans => base.transform as RectTransform;

	public TabState state { get; protected set; }

	public TabState previous_state { get; protected set; }

	public bool locked { get; protected set; }

	protected override void Start()
	{
		base.Start();
		moveToState(starting_state);
		locked = lock_starting_state;
	}

	protected virtual void moveToState(TabState _state)
	{
		if (!locked && state != _state)
		{
			previous_state = state;
			state = _state;
			moving_coroutine.stopCoroutineIfSome(this);
			moving_coroutine = moving_coroutine.start(rect_trans.anchoredMove(getStatePosition(_state), state_change_duration, CoroutineExtensions.easeInOutFunc), this);
		}
	}

	protected virtual Vector3 getStatePosition(TabState _state)
	{
		return _state switch
		{
			TabState.CLOSED => closed_pos, 
			TabState.HOVERING => hover_pos, 
			TabState.OPEN => selected_pos, 
			TabState.HIDDEN => hidden_pos, 
			_ => throw new ArgumentException($"No position set for state {_state}!"), 
		};
	}

	public void hover()
	{
		moveToState(TabState.HOVERING);
	}

	public void open()
	{
		moveToState(TabState.OPEN);
	}

	public void close()
	{
		moveToState(TabState.CLOSED);
	}

	public void hide()
	{
		moveToState(TabState.HIDDEN);
	}

	public void openAndLock()
	{
		moveToState(TabState.OPEN);
		locked = true;
	}

	public void hideAndLock()
	{
		moveToState(TabState.HIDDEN);
		locked = true;
	}

	public void unlock()
	{
		locked = false;
	}

	public void unlockAndClose()
	{
		unlock();
		close();
	}

	public override void OnPointerEnter(PointerEventData eventData)
	{
		base.OnPointerEnter(eventData);
		hover();
	}

	public override void OnPointerExit(PointerEventData eventData)
	{
		base.OnPointerExit(eventData);
		close();
	}

	public override void OnPointerUp(PointerEventData eventData)
	{
		base.OnPointerUp(eventData);
		if (open_on_click)
		{
			if (lock_on_click)
			{
				openAndLock();
			}
			else
			{
				open();
			}
		}
	}
}
