using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Unity;
using GRGLib.Maybe;
using GRGLib.Serializable;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Visual;

public class BackAlleysPouchVisualManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private ItemVisualHelper item_visual_helper;

	[SerializeField]
	private RectTransform slots_parent;

	[SerializeField]
	private SerializableDictionary<Vector2Int, BackAlleysSlotVisual> slots;

	[SerializeField]
	private BackAlleysItemInfoVisualManager item_info_manager;

	private Action<Vector2Int, Vector2Int> exchange_items;

	public void setUp(Action<Vector2Int, IHaveAbility> _ability, Action<Vector2Int, Vector2Int> _exchange_items, RectTransform _drag_parent, BoardVisualManager _board_manager)
	{
		exchange_items = _exchange_items;
		foreach (KeyValuePair<Vector2Int, BackAlleysSlotVisual> slot in slots)
		{
			slot.Value.setUp(slot.Key, item_visual_helper, _drag_parent, _ability, onSlotDrag, onSlotDragEnd);
		}
		setUpSelectables(_board_manager);
		onDeviceChange(GameHandler.instance.using_gamepad);
	}

	private void setUpSelectables(BoardVisualManager _board)
	{
		_board.empty_slots.Where((KeyValuePair<Vector2Int, EmptySlot> _s) => _s.Key.x == 0).ToList().ForEach(delegate(KeyValuePair<Vector2Int, EmptySlot> _s)
		{
			_s.Value.setUpLeftNavigation(((_s.Key.y < 2) ? slots[new Vector2Int(1, 0)] : slots[new Vector2Int(1, 1)]).getButton());
		});
		slots[new Vector2Int(1, 0)].getButton().setNavigationRight(_board.empty_slots[new Vector2Int(0, 1)].getSelectable());
		slots[new Vector2Int(1, 1)].getButton().setNavigationRight(_board.empty_slots[new Vector2Int(0, 2)].getSelectable());
	}

	public void setUpSelection(RectTransform _drag_parent, _dep_BackAlleysRegionState _state)
	{
		exchange_items = delegate
		{
		};
		foreach (KeyValuePair<Vector2Int, BackAlleysSlotVisual> slot in slots)
		{
			slot.Value.setUp(slot.Key, item_visual_helper, _drag_parent, delegate
			{
			}, onSlotDrag, onSlotDragEnd, _useable: false);
		}
		renew(_state.pouch);
	}

	public void renew(BackAlleysCaseSnapshot _snap)
	{
		renew(_snap.back_alleys_payload.pouch);
		item_info_manager.renew(_snap.back_alleys_payload.pouch.item_info);
	}

	public void renew(BackAlleysPouch _pouch)
	{
		foreach (KeyValuePair<Vector2Int, BackAlleysSlotVisual> slot in slots)
		{
			slot.Value.renew(_pouch.item_slots[slot.Key]);
		}
	}

	public Maybe<Vector2Int> getFirstFreeSlot()
	{
		foreach (KeyValuePair<Vector2Int, BackAlleysSlotVisual> slot in slots)
		{
			if (!slot.Value.is_full)
			{
				return slot.Key.maybe();
			}
		}
		return new Maybe<Vector2Int>();
	}

	public RectTransform getSlotsParent()
	{
		return slots_parent;
	}

	public void selectFirstSlot()
	{
		slots[new Vector2Int(0, 0)].getButton().Select();
	}

	private void onSlotDrag(BackAlleysSlotVisual _slot)
	{
		foreach (KeyValuePair<Vector2Int, BackAlleysSlotVisual> slot in slots)
		{
			slot.Value.setHoverCallbacks(_slot.setExchanger, _slot.removeExchanger);
		}
	}

	private void onSlotDragEnd(Maybe<(Vector2Int, Vector2Int)> _exchange)
	{
		foreach (KeyValuePair<Vector2Int, BackAlleysSlotVisual> slot in slots)
		{
			slot.Value.resetHoverCallbacks();
		}
		if (_exchange.is_some)
		{
			exchange_items(_exchange.value.Item1, _exchange.value.Item2);
		}
	}

	public void setOnClickCallbacks(Action<BackAlleysSlotVisual> _on_click)
	{
		foreach (KeyValuePair<Vector2Int, BackAlleysSlotVisual> slot in slots)
		{
			slot.Value.setClickCallback(_on_click);
		}
	}

	public void resetClickCallbacks()
	{
		foreach (KeyValuePair<Vector2Int, BackAlleysSlotVisual> slot in slots)
		{
			slot.Value.resetClickCallback();
		}
	}

	public void onControllerSouth(InputAction.CallbackContext _context)
	{
		foreach (KeyValuePair<Vector2Int, BackAlleysSlotVisual> slot in slots)
		{
			slot.Value.onControllerSouth(_context);
		}
	}

	public void onDeviceChange(PlayerInput _player_input)
	{
		onDeviceChange(_player_input.isUsingGamepad());
	}

	private void onDeviceChange(bool using_controller)
	{
		foreach (KeyValuePair<Vector2Int, BackAlleysSlotVisual> slot in slots)
		{
			slot.Value.onDeviceChange(using_controller);
		}
	}
}
