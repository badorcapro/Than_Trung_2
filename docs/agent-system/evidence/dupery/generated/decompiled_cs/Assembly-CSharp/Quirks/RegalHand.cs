using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class RegalHand : CaseQuirkData
{
	private const int chips_gain = 30;

	public override CaseQuirks quirk_type => CaseQuirks.REGAL_HAND;

	protected override string english_name => "Regal Hand";

	protected override string english_description => $"The first time in each {Keywords.CASE.toString()} you have 2 {TextHelper.faceCards}, gain {30} {TextHelper.chips_with_link}.";

	public override string description_white => base.description.colourSpriteLink("chip", Color.white);

	public override bool is_case_start_quirk => true;

	public override bool is_card_reaction_quirk => true;

	public RegalHand(bool _completed)
	{
		base.quirk_completed = _completed;
	}

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CASINO;
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		if (!(_case is CasinoCase casinoCase))
		{
			Debug.LogError($"{quirk_type} is a casino quirk! It is not valid in {_case.case_type}!");
			return _board;
		}
		if (casinoCase.left_card.is_face_card && casinoCase.right_card.is_face_card)
		{
			base.quirk_completed = true;
			casinoCase.gainChips(30);
		}
		return _board;
	}

	public override void onCardChange(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCase _case, List<CasinoCard> _discarded, List<CasinoCard> _new_cards, System.Random _rng)
	{
		if (!base.quirk_completed && !(_case.left_card == null) && !(_case.right_card == null) && _case.left_card.is_face_card && _case.right_card.is_face_card)
		{
			base.quirk_completed = true;
			_case.gainChips(30);
		}
	}
}
