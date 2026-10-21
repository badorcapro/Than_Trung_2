using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class BackAlleysPouch
{
	public const char save_split_marker = '~';

	private Action<BackAlleysItemType> on_used;

	private Action<BackAlleysItem, bool, Action<Maybe<Vector2Int>>> try_add_item;

	public Dictionary<Vector2Int, BackAlleySlot> item_slots { get; private set; }

	public List<BackAlleysItem> waiting_to_be_added { get; private set; }

	public BackAlleySlot item_slot_1 => item_slots[new Vector2Int(0, 0)];

	public BackAlleySlot item_slot_2 => item_slots[new Vector2Int(1, 0)];

	public BackAlleySlot item_slot_3 => item_slots[new Vector2Int(0, 1)];

	public BackAlleySlot item_slot_4 => item_slots[new Vector2Int(1, 1)];

	public List<string> item_info { get; private set; } = new List<string>();

	public List<BackAlleySlot> all_slots => new List<BackAlleySlot> { item_slot_1, item_slot_2, item_slot_3, item_slot_4 };

	public List<BackAlleySlot> filled_slots => all_slots.Where((BackAlleySlot _s) => _s.is_full).ToList();

	public List<BackAlleySlot> empty_slots => all_slots.Where((BackAlleySlot _s) => !_s.is_full).ToList();

	public int nb_slots_filled => filled_slots.Count;

	public BackAlleysPouch(Action<BackAlleysItemType> _use_item, Action<BackAlleysItem, bool, Action<Maybe<Vector2Int>>> _add_item)
	{
		on_used = _use_item;
		try_add_item = _add_item;
		setUpItemSlotsEmpty();
	}

	public BackAlleysPouch(BackAlleysPouch _pouch, Action<BackAlleysItemType> _use_item, Action<BackAlleysItem, bool, Action<Maybe<Vector2Int>>> _add_item)
	{
		on_used = _use_item;
		try_add_item = _add_item;
		item_slots = _pouch.item_slots.copy();
	}

	public BackAlleysPouch(BackAlleyPouchSaveData _save_data, System.Random _rng, Action<BackAlleysItemType> _use_item, Action<BackAlleysItem, bool, Action<Maybe<Vector2Int>>> _add_item)
	{
		on_used = _use_item;
		try_add_item = _add_item;
		try
		{
			item_slots = new Dictionary<Vector2Int, BackAlleySlot>();
			for (int i = 0; i < _save_data.item_slots.Count; i++)
			{
				Vector2Int vector2Int = new Vector2Int(i % 2, i / 2);
				item_slots[vector2Int] = new BackAlleySlot(_save_data.item_slots[i], vector2Int, _rng, on_used);
			}
			item_info = _save_data.info.copy();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! Back Alleys Pouch! ({_save_data}) | Error: {arg}");
			setUpItemSlotsEmpty();
			item_info = new List<string>();
		}
	}

	private void setUpItemSlotsEmpty()
	{
		item_slots = new Dictionary<Vector2Int, BackAlleySlot>
		{
			{
				new Vector2Int(0, 0),
				new BackAlleySlot(new Vector2Int(0, 0), on_used)
			},
			{
				new Vector2Int(1, 0),
				new BackAlleySlot(new Vector2Int(1, 0), on_used)
			},
			{
				new Vector2Int(0, 1),
				new BackAlleySlot(new Vector2Int(0, 1), on_used)
			},
			{
				new Vector2Int(1, 1),
				new BackAlleySlot(new Vector2Int(1, 1), on_used)
			}
		};
	}

	public bool fillNextItemSlot(BackAlleysItemType _item, System.Random _rng)
	{
		if (empty_slots.Count == 0)
		{
			Debug.LogError($"No available Slot to fill with item {_item}!");
			return false;
		}
		empty_slots[0].fillSlot(_item.createItem(_rng));
		return true;
	}

	public bool replaceItemSlot(Vector2Int _slot, BackAlleysItemType _item, System.Random _rng)
	{
		item_slots[_slot].fillSlot(_item.createItem(_rng));
		return true;
	}

	public void swapItems(Vector2Int _slot_1, Vector2Int _slot_2)
	{
		item_slots[_slot_1].exchangeItem(item_slots[_slot_2].exchangeItem(item_slots[_slot_1].item));
	}

	public void gainItem(BackAlleysItemType _item, System.Random _rng, bool _forced_addition = false)
	{
		gainItem(_item.createItem(_rng), _forced_addition);
	}

	public void gainItem(BackAlleysItem _item, bool _forced_addition = false)
	{
		try_add_item(_item, _forced_addition, delegate(Maybe<Vector2Int> _add)
		{
			if (_add.is_some)
			{
				if (item_slots[_add.value].is_full)
				{
					item_slots[_add.value].destroyFilledItem();
				}
				item_slots[_add.value].fillSlot(_item);
			}
		});
	}

	public Maybe<BackAlleysItem> stealItem(System.Random _rng)
	{
		List<BackAlleySlot> list = filled_slots;
		if (list.Count == 0)
		{
			return new Maybe<BackAlleysItem>();
		}
		BackAlleySlot randomElementFromList = list.getRandomElementFromList(_rng);
		BackAlleysItem value = randomElementFromList.item.value;
		randomElementFromList.destroyFilledItem();
		return value.maybe();
	}

	public void onCaseBegin(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case)
	{
		filled_slots.ForEach(delegate(BackAlleySlot _s)
		{
			_s.item.value.onCaseBegin(_board, _case);
		});
	}

	public bool tryUseAbility(Vector2Int _slot, List<AbilityData> _data, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case)
	{
		if (!item_slots[_slot].is_full)
		{
			Debug.LogError("Trying to use the ability of a none-existing item!");
			return false;
		}
		filled_slots.ForEach(delegate(BackAlleySlot _s)
		{
			if (_s.position != _slot)
			{
				_s.item.value.onItemUsed(_board, item_slots[_slot], _case);
			}
		});
		item_slots[_slot].item.value.useItemAbility(_board, _data, _case);
		return true;
	}

	public int onHealthChange(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case, int _health, int _current_change)
	{
		return filled_slots.Aggregate(_current_change, (int _a, BackAlleySlot _s) => _s.item.value.onHealthChange(_board, _case, _health, _a));
	}

	public void onArrest(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case, int _arresting)
	{
		filled_slots.ForEach(delegate(BackAlleySlot _s)
		{
			_s.item.value.onArrest(_board, _case, _arresting);
		});
	}

	public void onCaseEnd(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case, bool _case_lost)
	{
		filled_slots.ForEach(delegate(BackAlleySlot _s)
		{
			_s.item.value.onCaseEnd(_board, _case, _case_lost);
		});
	}

	public int setItemInfo(string _info)
	{
		item_info.Add(_info);
		return item_info.Count - 1;
	}

	public BackAlleyPouchSaveData toSaveData()
	{
		return new BackAlleyPouchSaveData(item_slot_1.toSaveData().makeListFromItem().add(item_slot_2.toSaveData())
			.add(item_slot_3.toSaveData())
			.add(item_slot_4.toSaveData()), item_info.copy());
	}
}
