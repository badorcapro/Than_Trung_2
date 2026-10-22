using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace BackAlleyItems;

public class FamilialLocket : BackAlleysItem
{
	public override BackAlleysItemType type => BackAlleysItemType.FAMILIAL_LOCKET;

	public override BackAlleysItemColour colour => BackAlleysItemColour.LAWFUL;

	public override BackAlleysItemCost cost => BackAlleysItemCost.CHEAP;

	protected override string english_name => "Familial Locket";

	protected override string english_description => "If all my other " + TextHelper.pockets + " are empty when solving a case, regain 1 " + Keywords.HEALTH.toString() + ".";

	public override int uses_per_case => 1;

	public override bool destroy_onced_used => false;

	public override bool is_active => false;

	public FamilialLocket(System.Random _rng, int _usages = -1)
		: base(_rng, _usages)
	{
	}

	public override void onCaseEnd(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case, bool _lost)
	{
		if (!_lost)
		{
			if (_case.pouch.nb_slots_filled == 1)
			{
				_case.addHealth(1);
				slot_reference.onItemUsed(type);
			}
			base.onCaseEnd(_board, _case, _lost);
		}
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}
}
