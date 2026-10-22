using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class DeadlyRoyals : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.DEADLY_ROYALS;

	protected override string english_name => "Deadly Royals";

	protected override string english_description => "Everytime a " + Keywords.FACE_CARD.toString() + " is discarded, a random non-" + TextHelper.traitorRole + " is " + TextHelper.killed + " if possible.";

	public override bool is_card_reaction_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CASINO;
	}

	public override void onCardChange(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCase _case, List<CasinoCard> _discarded, List<CasinoCard> _new_cards, System.Random _rng)
	{
		if (_discarded.Count == 0)
		{
			return;
		}
		int num = _discarded.Count((CasinoCard _c) => _c.is_face_card);
		if (num == 0)
		{
			return;
		}
		List<RoleData> list = (from _r in _board.getRolesInPlayOfClass(RoleClassifications.INNOCENT, RoleClassifications.MEDDLER, RoleClassifications.UNDERLING)
			where !_r.getIsDead()
			select _r).ToList();
		if (list.Count == 0)
		{
			return;
		}
		foreach (RoleData randomElementsFrom in list.getRandomElementsFromList(_rng, Mathf.Min(list.Count, num)))
		{
			_case.killAddress(randomElementsFrom.getAddress(), new Maybe<RoleData>());
		}
	}
}
