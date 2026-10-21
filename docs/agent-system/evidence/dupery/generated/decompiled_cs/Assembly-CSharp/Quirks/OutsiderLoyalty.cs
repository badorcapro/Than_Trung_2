using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class OutsiderLoyalty : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.OUTSIDER_LOYALTY;

	protected override string english_name => "Outsider Loyalty";

	protected override string english_description => "You lose one more " + Keywords.REPUTATION.toString() + " if you " + Keywords.ARREST.toString() + " a " + TextHelper.goodRole + " that is on the edge of the " + Keywords.BOARD.toString() + ".";

	public override bool is_arrest_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type switch
		{
			CaseType.CLOCK => true, 
			CaseType.DOCKS => true, 
			_ => false, 
		};
	}

	public override void onArrest(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, RoleData _arrested_role, System.Random _rng)
	{
		if (_arrested_role.getTrueAlignment() == Alignments.EVIL)
		{
			return;
		}
		Action<int> action;
		if (_case is ClockCase @object)
		{
			action = @object.addReputation;
		}
		else
		{
			if (!(_case is DocksCase object2))
			{
				throw new ArgumentException($"No reduce rep function set up for case type {_case.case_type}!");
			}
			action = object2.addReputation;
		}
		if (_arrested_role.getBoardPosition().isEdgePositionOnGrid(_case.board_size))
		{
			action(-1);
		}
	}
}
