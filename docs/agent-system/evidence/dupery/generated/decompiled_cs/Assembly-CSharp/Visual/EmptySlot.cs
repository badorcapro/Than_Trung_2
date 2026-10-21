using System;
using GRGLib.Maybe;
using GRGLib.UI;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class EmptySlot : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private AdvancedButton button;

	private Action<EmptySlot, Vector2Int> on_select;

	private Action<EmptySlot, Vector2Int> on_deselect;

	private Action<EmptySlot, Vector2Int> on_south_down;

	private Action<EmptySlot, Vector2Int> on_south_up;

	private Action<EmptySlot, Vector2Int> on_west_down;

	private Action<EmptySlot, Vector2Int> on_west_up;

	private Action<EmptySlot, Vector2Int> on_left_start;

	private Maybe<Action<EmptySlot, Vector2Int>> on_hover = new Maybe<Action<EmptySlot, Vector2Int>>();

	private Maybe<Action<EmptySlot, Vector2Int>> on_unhover = new Maybe<Action<EmptySlot, Vector2Int>>();

	private Maybe<Action<EmptySlot, Vector2Int>> override_click = new Maybe<Action<EmptySlot, Vector2Int>>();

	public Vector2Int grid_pos { get; private set; }

	public bool is_hovering { get; private set; }

	public void setUp(Vector2Int _grid_pos, Action<EmptySlot, Vector2Int> _on_select, Action<EmptySlot, Vector2Int> _on_deselect, Action<EmptySlot, Vector2Int> _on_south_down, Action<EmptySlot, Vector2Int> _on_south_up, Action<EmptySlot, Vector2Int> _on_west_down, Action<EmptySlot, Vector2Int> _on_west_up, Action<EmptySlot, Vector2Int> _on_left_start)
	{
		grid_pos = _grid_pos;
		on_select = _on_select;
		on_deselect = _on_deselect;
		on_south_down = _on_south_down;
		on_south_up = _on_south_up;
		on_west_down = _on_west_down;
		on_west_up = _on_west_up;
		on_left_start = _on_left_start;
	}

	public void setUpOverride(Action<EmptySlot, Vector2Int> _on_hover, Action<EmptySlot, Vector2Int> _on_unhover, Action<EmptySlot, Vector2Int> _override_click)
	{
		Maybe<Action<EmptySlot, Vector2Int>> maybe = _on_hover.maybe();
		Maybe<Action<EmptySlot, Vector2Int>> maybe2 = _on_unhover.maybe();
		Maybe<Action<EmptySlot, Vector2Int>> maybe3 = _override_click.maybe();
		on_hover = maybe;
		on_unhover = maybe2;
		override_click = maybe3;
	}

	public void resetOverride()
	{
		Maybe<Action<EmptySlot, Vector2Int>> maybe = new Maybe<Action<EmptySlot, Vector2Int>>();
		Maybe<Action<EmptySlot, Vector2Int>> maybe2 = new Maybe<Action<EmptySlot, Vector2Int>>();
		Maybe<Action<EmptySlot, Vector2Int>> maybe3 = new Maybe<Action<EmptySlot, Vector2Int>>();
		on_hover = maybe;
		on_unhover = maybe2;
		override_click = maybe3;
	}

	public void onHover()
	{
		is_hovering = true;
		if (on_hover.is_some)
		{
			on_hover.value(this, grid_pos);
		}
	}

	public void onUnhover()
	{
		is_hovering = false;
		if (on_unhover.is_some)
		{
			on_unhover.value(this, grid_pos);
		}
	}

	public void onClick()
	{
		if (override_click.is_some)
		{
			override_click.value(this, grid_pos);
		}
	}

	public Selectable getSelectable()
	{
		return button;
	}

	public void setUpNavigation(Selectable _left, Selectable _right, Selectable _up, Selectable _down, bool _override_down = true)
	{
		Navigation navigation = button.navigation;
		navigation.selectOnLeft = _left;
		navigation.selectOnRight = _right;
		navigation.selectOnUp = _up;
		navigation.selectOnDown = ((_override_down || _down != null) ? _down : navigation.selectOnDown);
		button.navigation = navigation;
	}

	public void setUpDownNavigation(Selectable _down)
	{
		Navigation navigation = button.navigation;
		navigation.selectOnDown = _down;
		button.navigation = navigation;
	}

	public void setUpLeftNavigation(Selectable _left)
	{
		Navigation navigation = button.navigation;
		navigation.selectOnLeft = _left;
		button.navigation = navigation;
	}

	public void forceSelect()
	{
		button.Select();
	}

	public void onSelect()
	{
		on_select(this, grid_pos);
	}

	public void onDeselect()
	{
		on_deselect(this, grid_pos);
	}

	public void onControllerSouth(bool _down)
	{
		if (override_click.is_some)
		{
			onClick();
		}
		else if (_down)
		{
			controllerSouthDownWithSlot();
		}
		else
		{
			controllerSouthUpWithSlot();
		}
	}

	private void controllerSouthDownWithSlot()
	{
		on_south_down(this, grid_pos);
	}

	private void controllerSouthUpWithSlot()
	{
		on_south_up(this, grid_pos);
	}

	public void onControllerWest(bool _down)
	{
		if (_down)
		{
			controllerWestDownWithSlot();
		}
		else
		{
			controllerWestUpWithSlot();
		}
	}

	private void controllerWestDownWithSlot()
	{
		on_west_down(this, grid_pos);
	}

	private void controllerWestUpWithSlot()
	{
		on_west_up(this, grid_pos);
	}

	public void onControllerLeftStart()
	{
		on_left_start(this, grid_pos);
	}
}
