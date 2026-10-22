using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace BackAlleyItems;

public class BundleOfString : BackAlleysItem
{
	public override BackAlleysItemType type => BackAlleysItemType.BUNDLE_OF_STRING;

	public override BackAlleysItemColour colour => BackAlleysItemColour.MISCHEVIOUS;

	public override BackAlleysItemCost cost => BackAlleysItemCost.PRICEY;

	protected override string english_name => "Bundle of String";

	protected override string english_description => "Once per case, when a multi-use item to my right is used, it does not reduce it's usage. Everytime this item triggers, it might be lost.";

	public override int uses_per_case => 1;

	public override bool destroy_onced_used => false;

	public override bool is_active => false;

	public BundleOfString(System.Random _rng, int _usages = -1)
		: base(_rng, _usages)
	{
	}

	public override void onItemUsed(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleySlot _item_slot, BackAlleysCase _case)
	{
		if (base.uses_remaining <= 0 || _item_slot.position != slot_reference.position + new Vector2Int(1, 0))
		{
			return;
		}
		if (!_item_slot.is_full)
		{
			Debug.LogError("Using an item that does not exist!!");
		}
		else if (_item_slot.item.value.uses_remaining >= 0)
		{
			_item_slot.item.value.increaseAvailableUsages();
			spendUse();
			if (random.Next(0, 2) == 1)
			{
				slot_reference.destroyFilledItem();
			}
		}
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}
}
