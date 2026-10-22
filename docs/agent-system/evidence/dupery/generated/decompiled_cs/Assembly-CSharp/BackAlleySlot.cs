using System;
using GRGLib.Maybe;
using UnityEngine;

public class BackAlleySlot
{
	public const string empty_slot_save_marker = "e";

	public readonly Vector2Int position;

	private Action<BackAlleysItemType> on_item_use;

	public Maybe<BackAlleysItem> item { get; private set; }

	public bool is_full => item.is_some;

	public BackAlleySlot(Vector2Int _position, Action<BackAlleysItemType> _use_item)
	{
		Maybe<BackAlleysItem> maybe = new Maybe<BackAlleysItem>();
		position = _position;
		Maybe<BackAlleysItem> maybe3 = (item = maybe);
		on_item_use = _use_item;
	}

	public BackAlleySlot(Vector2Int _position, BackAlleysItem _item, Action<BackAlleysItemType> _use_item)
	{
		Maybe<BackAlleysItem> maybe = _item.maybe();
		position = _position;
		Maybe<BackAlleysItem> maybe3 = (item = maybe);
		on_item_use = _use_item;
	}

	public BackAlleySlot(string _save_data, Vector2Int _position, System.Random _rng, Action<BackAlleysItemType> _use_item)
	{
		on_item_use = _use_item;
		position = _position;
		if (_save_data == "e")
		{
			item = new Maybe<BackAlleysItem>();
			return;
		}
		try
		{
			item = BackAlleysItem.load(_save_data, destroyFilledItem, _rng).maybe();
			item.value.setSlotReference(this);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! Item! ({_save_data})\nError: {arg}");
			item = new Maybe<BackAlleysItem>();
		}
	}

	public void fillSlot(BackAlleysItem _item)
	{
		_item.setSlotReference(this);
		item = _item.maybe();
	}

	public Maybe<BackAlleysItem> exchangeItem(Maybe<BackAlleysItem> _item)
	{
		Maybe<BackAlleysItem> result = item;
		item = _item;
		if (item.is_some)
		{
			item.value.setSlotReference(this);
		}
		return result;
	}

	public void destroyFilledItem()
	{
		item = new Maybe<BackAlleysItem>();
	}

	public void onItemUsed(BackAlleysItemType _item)
	{
		on_item_use(_item);
	}

	public string toSaveData()
	{
		if (is_full)
		{
			return item.value.toSaveData();
		}
		return "e";
	}
}
