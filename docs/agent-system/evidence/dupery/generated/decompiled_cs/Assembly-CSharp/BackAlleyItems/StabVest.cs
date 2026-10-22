using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace BackAlleyItems;

public class StabVest : BackAlleysItem
{
	public override BackAlleysItemType type => BackAlleysItemType.STAB_VEST;

	public override BackAlleysItemColour colour => BackAlleysItemColour.LAWFUL;

	public override BackAlleysItemCost cost => BackAlleysItemCost.EXPENSIVE;

	protected override string english_name => "Stab Vest";

	protected override string english_description => "The first time your " + Keywords.REPUTATION.toString() + " would reach 0 or below, it becomes 1 instead and this item is lost.";

	public override bool is_active => false;

	private string loc_comment_key => $"{type} [cmnt]";

	public StabVest(System.Random _rng, int _usages = -1)
		: base(_rng, _usages)
	{
	}

	public override int onHealthChange(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case, int _old_rep, int _current_change)
	{
		if (_old_rep + _current_change <= 0)
		{
			slot_reference.onItemUsed(type);
			slot_reference.destroyFilledItem();
			return 1 - _old_rep;
		}
		return base.onHealthChange(_board, _case, _old_rep, _current_change);
	}

	private string englishComment()
	{
		return "Detective saved by Stab Vest!";
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}
}
