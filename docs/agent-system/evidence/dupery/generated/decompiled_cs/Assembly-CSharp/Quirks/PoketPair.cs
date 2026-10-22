using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class PoketPair : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.POCKET_PAIR;

	protected override string english_name => "Pocket Pair";

	protected override string english_description => "Whenever both your " + TextHelper.cards + " have the same " + TextHelper.value + ", a random " + TextHelper.innocentRole + " dies if possible.";

	public override bool is_card_reaction_quirk => true;

	public override bool is_case_start_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CASINO;
	}

	public override void onCardChange(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCase _case, List<CasinoCard> _discarded, List<CasinoCard> _new_cards, System.Random _rng)
	{
		if (_new_cards.Count != 0 && !(_case.left_card == null) && !(_case.right_card == null) && _case.left_card.value == _case.right_card.value)
		{
			tryKillRandomnInnocent(_case, _board, _rng);
		}
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		if (!(_case is CasinoCase casinoCase))
		{
			Debug.LogError($"{quirk_type} is a Casino exclusive quirk. Why is it in a {_case.case_type} case!");
			return _board;
		}
		if (casinoCase.left_card.value == casinoCase.right_card.value)
		{
			tryKillRandomnInnocent(casinoCase, _board, _rng);
		}
		return _board;
	}

	private void tryKillRandomnInnocent(CasinoCase _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		List<RoleData> list = (from _r in _board.getRolesInPlayOfClass(default(RoleClassifications))
			where !_r.getIsDead()
			select _r).ToList();
		if (list.Count != 0)
		{
			_case.killAddress(list.getRandomElementFromList(_rng).getAddress(), new Maybe<RoleData>());
		}
	}
}
