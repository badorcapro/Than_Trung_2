using System;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Visual;

public class BackAlleysSlotVisual : MonoBehaviour, IAmItemVisualised
{
	[SerializeField]
	private BackAlleysItemVisualDataSO item_visuals_so;

	[Header("References")]
	[SerializeField]
	private RectTransform item_parent;

	[SerializeField]
	private Button selectable;

	[Header("Prefabs")]
	[SerializeField]
	private BackAlleysItemVisual item_prefab;

	private ItemVisualHelper v_helper;

	private Action<Vector2Int, IHaveAbility> attempt_ability;

	private CoroutineRunner test_drag;

	private RectTransform drag_parent;

	private Action<BackAlleysSlotVisual> on_drag;

	private Action<Maybe<(Vector2Int, Vector2Int)>> on_drag_end;

	private Maybe<Action<BackAlleysSlotVisual>> on_hover_override = new Maybe<Action<BackAlleysSlotVisual>>();

	private Maybe<Action<BackAlleysSlotVisual>> on_unhover_override = new Maybe<Action<BackAlleysSlotVisual>>();

	private Maybe<Action<BackAlleysSlotVisual>> on_click_override = new Maybe<Action<BackAlleysSlotVisual>>();

	private Maybe<BackAlleysItemVisual> item_in_slot = new Maybe<BackAlleysItemVisual>();

	private Maybe<BackAlleysSlotVisual> exchanger = new Maybe<BackAlleysSlotVisual>();

	private bool is_hovering;

	private bool can_be_used = true;

	public Vector2Int slot_position { get; private set; }

	public MonoBehaviour mono => this;

	public bool is_full => item_in_slot.is_some;

	public string title
	{
		get
		{
			if (!is_full)
			{
				return "";
			}
			return item_in_slot.value.item_name;
		}
	}

	public string colour_name
	{
		get
		{
			if (!is_full)
			{
				return "";
			}
			return item_in_slot.value.colour.toString();
		}
	}

	public string description
	{
		get
		{
			if (!is_full)
			{
				return "";
			}
			return item_in_slot.value.item_description;
		}
	}

	public Button getButton()
	{
		return selectable;
	}

	public void setUp(Vector2Int _pos, ItemVisualHelper _item_vhelp, RectTransform _drag_parent, Action<Vector2Int, IHaveAbility> _attempt_ability, Action<BackAlleysSlotVisual> _on_drag, Action<Maybe<(Vector2Int, Vector2Int)>> _end_drag, bool _useable = true)
	{
		test_drag = new CoroutineRunner(this);
		drag_parent = _drag_parent;
		slot_position = _pos;
		attempt_ability = _attempt_ability;
		v_helper = _item_vhelp;
		on_drag = _on_drag;
		on_drag_end = _end_drag;
		can_be_used = _useable;
	}

	public void renew(BackAlleySlot _slot)
	{
		if (_slot.is_full)
		{
			if (!item_in_slot.is_some)
			{
				item_in_slot = UnityEngine.Object.Instantiate(item_prefab, item_parent).maybe();
				item_in_slot.value.setUp(_slot.item.value, item_visuals_so[_slot.item.value.type]);
			}
			else if (item_in_slot.value.type == _slot.item.value.type)
			{
				item_in_slot.value.renew(_slot.item.value);
			}
			else
			{
				item_in_slot.value.destroySelf();
				item_in_slot = new Maybe<BackAlleysItemVisual>();
				renew(_slot);
			}
		}
		else if (item_in_slot.is_some)
		{
			v_helper.tryClose(this);
			item_in_slot.value.destroySelf();
			item_in_slot = new Maybe<BackAlleysItemVisual>();
		}
	}

	public void setHoverCallbacks(Action<BackAlleysSlotVisual> _on_hover, Action<BackAlleysSlotVisual> _leave_hover)
	{
		on_hover_override = _on_hover.maybe();
		on_unhover_override = _leave_hover.maybe();
		if (is_hovering)
		{
			v_helper.tryClose(this);
			on_hover_override.value(this);
		}
	}

	public void resetHoverCallbacks()
	{
		on_hover_override = new Maybe<Action<BackAlleysSlotVisual>>();
		on_unhover_override = new Maybe<Action<BackAlleysSlotVisual>>();
	}

	public void setClickCallback(Action<BackAlleysSlotVisual> _on_click)
	{
		on_click_override = _on_click.maybe();
	}

	public void resetClickCallback()
	{
		on_click_override = new Maybe<Action<BackAlleysSlotVisual>>();
	}

	public void onHover()
	{
		if (on_hover_override.is_some)
		{
			on_hover_override.value(this);
			return;
		}
		is_hovering = true;
		v_helper.checkDestination(this, base.transform.position);
	}

	public void onUnhover()
	{
		if (on_unhover_override.is_some)
		{
			on_unhover_override.value(this);
			return;
		}
		is_hovering = false;
		v_helper.tryClose(this);
	}

	private void onClick()
	{
		if (on_click_override.is_some)
		{
			on_click_override.value(this);
		}
		else if (can_be_used && item_in_slot.is_some && item_in_slot.value.item_data is IHaveAbility { abilityExhausted: false } haveAbility)
		{
			attempt_ability(slot_position, haveAbility);
		}
	}

	public void onDrag()
	{
		if (is_full)
		{
			item_in_slot.value.transform.SetParent(drag_parent);
			item_in_slot.value.setInteractableState(_interactable: false);
			item_in_slot.value.dragItem(onDragEnd);
			on_drag(this);
		}
	}

	private void onDragEnd()
	{
		if (exchanger.is_some)
		{
			item_in_slot = exchanger.value.tryExchangeItems(item_in_slot);
		}
		moveItemBackToBase();
		on_drag_end(exchanger.is_some ? (slot_position, exchanger.value.slot_position).maybe() : new Maybe<(Vector2Int, Vector2Int)>());
		exchanger = new Maybe<BackAlleysSlotVisual>();
	}

	public void setExchanger(BackAlleysSlotVisual _slot)
	{
		if (GameHandler.instance.using_gamepad)
		{
			item_in_slot.value.controllerDragItemToSlot(_slot);
		}
		if (_slot == this)
		{
			exchanger = new Maybe<BackAlleysSlotVisual>();
		}
		else
		{
			exchanger = _slot.maybe();
		}
	}

	public void removeExchanger(BackAlleysSlotVisual _slot)
	{
		if (exchanger.is_some && exchanger.value == _slot)
		{
			exchanger = new Maybe<BackAlleysSlotVisual>();
		}
	}

	public Maybe<BackAlleysItemVisual> tryExchangeItems(Maybe<BackAlleysItemVisual> _item)
	{
		Maybe<BackAlleysItemVisual> result = item_in_slot;
		item_in_slot = _item;
		moveItemBackToBase();
		return result;
	}

	public void removeItem()
	{
		if (is_full)
		{
			item_in_slot.value.destroySelf();
			item_in_slot = new Maybe<BackAlleysItemVisual>();
		}
	}

	private void moveItemBackToBase()
	{
		if (item_in_slot.is_some)
		{
			item_in_slot.value.transform.SetParent(item_parent);
			item_in_slot.value.setInteractableState(_interactable: true);
			item_in_slot.value.transform.moveTransform(new Vector3(0f, 0f), 0.45f, CoroutineExtensions.easeInOutFunc).start(this);
		}
	}

	public void onPointerDown()
	{
		test_drag.run(0.35f.wait(onDrag));
	}

	public void onPointerUp()
	{
		if (test_drag.is_running)
		{
			test_drag.stop();
			onClick();
		}
	}

	public void onControllerSouth(InputAction.CallbackContext _context)
	{
		if (item_in_slot.is_some && item_in_slot.value.wait_controller_release && _context.canceled)
		{
			item_in_slot.value.controllerReleased();
		}
		else if (is_hovering)
		{
			if (_context.canceled && test_drag.is_running)
			{
				test_drag.stop();
				onClick();
			}
			if (_context.performed)
			{
				test_drag.run(0.35f.wait(onDrag));
			}
		}
	}

	public void onDeviceChange(bool _using_controller)
	{
		selectable.transition = (_using_controller ? Selectable.Transition.ColorTint : Selectable.Transition.None);
	}
}
