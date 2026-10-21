using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class Refuel : CaseQuirkData
{
	private int fuel_regain = 1;

	public override CaseQuirks quirk_type => CaseQuirks.REFUEL;

	protected override string english_name => "Refuel";

	protected override string english_description => $"Regain {fuel_regain} {Keywords.FUEL.toString()} each time you {Keywords.ARREST.toString()} an {TextHelper.evilRole}.";

	public override string credit => "gv";

	public override bool is_arrest_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.DOCKS;
	}

	public override void onArrest(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, RoleData _arrested_role, System.Random _rng)
	{
		if (_arrested_role.getTrueAlignment() == Alignments.EVIL)
		{
			if (!(_case is DocksCase docksCase))
			{
				Debug.LogError($"{quirk_type} is a docks quirk but is in case that isnt a docks case! ({_case.case_type})");
			}
			else
			{
				docksCase.addFuel(fuel_regain);
			}
		}
	}
}
