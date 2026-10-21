using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class GamblersFallacy : CaseQuirkData
{
	private const int threshold = 3;

	public override CaseQuirks quirk_type => CaseQuirks.GAMBLER_FALLACY;

	protected override string english_name => "Gambler's Fallacy";

	protected override string english_description => $"When you {Keywords.ARREST.toString()} {3} {TextHelper.goodRoles} in a {Keywords.CASE.toString()}, lose all your {TextHelper.chips_with_link}.";

	public override string description_white => base.description.colourSpriteLink("chip", Color.white);

	public override bool is_arrest_quirk => true;

	public GamblersFallacy(bool _completed)
	{
		base.quirk_completed = _completed;
	}

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CASINO;
	}

	public override void onArrest(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, RoleData _arrested_role, System.Random _rng)
	{
		if (!base.quirk_completed && _arrested_role.getVisualAlignment() == Alignments.GOOD)
		{
			if (!(_case is CasinoCase casinoCase))
			{
				Debug.LogError($"{quirk_type} is a casino case quirk. Cannot be applied in {_case.case_type}!");
			}
			else if (_board.getAllArrestedRoles().Count((RoleData _r) => _r.getVisualAlignment() == Alignments.GOOD) >= 3)
			{
				casinoCase.spendChips(casinoCase.chips);
				base.quirk_completed = true;
			}
		}
	}
}
