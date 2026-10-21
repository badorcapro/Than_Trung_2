using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class DrawRight : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.DRAW_RIGHT;

	protected override string english_name => "Draw Right";

	protected override string english_description => "Everytime you " + Keywords.INVESTIGATE.toString() + " a " + Keywords.ROLE.toString() + ", discard your right " + Keywords.CARD.toString() + ".";

	public override bool is_investigate_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CASINO;
	}

	public override void onInvestigate(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _address, System.Random _rng)
	{
		if (!(_case is CasinoCase casinoCase))
		{
			Debug.LogError($"{quirk_type} is a casino quirk! Cannot be in case {_case.case_type}!");
		}
		else
		{
			casinoCase.drawNewCards(_left_card: false);
		}
	}
}
