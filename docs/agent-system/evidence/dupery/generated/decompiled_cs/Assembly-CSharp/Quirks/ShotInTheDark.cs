using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class ShotInTheDark : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.SHOT_IN_THE_DARK;

	protected override string english_name => "Shot in the Dark";

	protected override string english_description => "The first time you " + Keywords.ARREST.toString() + " an " + Keywords.UNINVESTIGATED.toString() + " " + TextHelper.evilRole + " this case, gain 1 " + Keywords.REPUTATION.toString() + ".";

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

	public ShotInTheDark(bool _completed)
	{
		base.quirk_completed = _completed;
	}

	public override void onArrest(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, RoleData _arrested_role, System.Random _rng)
	{
		if (!base.quirk_completed && !_arrested_role.getIsInvestigated() && _arrested_role.getTrueAlignment() == Alignments.EVIL)
		{
			if (_case is ClockCase clockCase)
			{
				clockCase.addReputation(1);
			}
			else if (_case is DocksCase docksCase)
			{
				docksCase.addReputation(1);
			}
			else
			{
				Debug.LogError($"No onArrest function set up for case type {_case.case_type}! {quirk_type}");
			}
			base.quirk_completed = true;
		}
	}
}
