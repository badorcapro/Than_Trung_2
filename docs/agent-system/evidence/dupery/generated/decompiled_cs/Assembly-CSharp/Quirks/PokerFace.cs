using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class PokerFace : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.POKER_FACE;

	protected override string english_name => "Poker Face";

	protected override string english_description => "If your starting 2 " + TextHelper.cards + " are of the same " + TextHelper.suit + ", a random " + Keywords.ROLE.toString() + " " + TextHelper.associated + " with that " + TextHelper.suit + " is " + TextHelper.obscured + ".";

	public override bool is_case_start_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CASINO;
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		if (!(_case is CasinoCase casinoCase))
		{
			Debug.LogError($"{quirk_type} is a casino quirk! Cannot be applied in case {_case.case_type}!");
			return _board;
		}
		if (casinoCase.left_card.suit != casinoCase.right_card.suit)
		{
			return _board;
		}
		List<RoleData> rolesInPlayOfClass = _board.getRolesInPlayOfClass(casinoCase.left_card.suit.toClass());
		if (rolesInPlayOfClass.Count == 0)
		{
			return _board;
		}
		rolesInPlayOfClass.getRandomElementFromList(_rng).setObscured(_new: true);
		return _board;
	}
}
