using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class RiggedDeck : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.RIGGED_DECK;

	protected override string english_name => "Rigged Deck";

	protected override string english_description => "If your starting 2 " + TextHelper.cards + " are of the same " + TextHelper.suit + ", a random " + TextHelper.innocentRole + " is " + TextHelper.tainted + ".";

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
		List<RoleData> rolesInPlayOfClass = _board.getRolesInPlayOfClass(default(RoleClassifications));
		if (rolesInPlayOfClass.Count == 0)
		{
			return _board;
		}
		rolesInPlayOfClass.getRandomElementFromList(_rng).setTainted(_new: true);
		return _board;
	}
}
