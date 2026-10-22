using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace BackAlleyItems;

public class FalsePoliceBadge : BackAlleysItem
{
	private bool triggering;

	public override BackAlleysItemType type => BackAlleysItemType.FALSE_POLICE_BADGE;

	public override BackAlleysItemColour colour => BackAlleysItemColour.BLACKMARKET;

	public override BackAlleysItemCost cost => BackAlleysItemCost.PRICEY;

	protected override string english_name => "False Police Badge";

	protected override string english_description => "The next time you " + Keywords.ARREST.toString() + " a " + TextHelper.goodRole + ", you do not lose any " + Keywords.REPUTATION.toString() + " and this item is lost.";

	public override bool is_active => false;

	public FalsePoliceBadge(System.Random _rng, int _usages = -1)
		: base(_rng, _usages)
	{
	}

	public override void onArrest(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case, int _arresting)
	{
		if (_board.getRolesInPlay()[_arresting].getTrueAlignment() == Alignments.GOOD)
		{
			triggering = true;
		}
	}

	public override int onHealthChange(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCase _case, int _old_rep, int _current_change)
	{
		if (triggering)
		{
			slot_reference.destroyFilledItem();
			slot_reference.onItemUsed(type);
			return 0;
		}
		return base.onHealthChange(_board, _case, _old_rep, _current_change);
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}
}
