using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class DecisionParalysis : CaseQuirkData
{
	private const string block_marker = "Quirk_DC";

	private int previous_block = -1;

	public override CaseQuirks quirk_type => CaseQuirks.DECISION_PARALYSIS;

	protected override string english_name => "Decision Paralysis";

	protected override string english_description => "If the summed " + TextHelper.value + " of your " + TextHelper.cards + " is equal to the " + Keywords.ADDRESS.toString() + " of a " + Keywords.ROLE.toString() + ", that " + Keywords.ROLE.toString() + " cannot be " + TextHelper.investigated + ".";

	protected override string english_extra_description => "A " + Keywords.FACE_CARD.toString() + "'s " + TextHelper.value + " is considered to be 10 for this quirk.";

	public override bool is_case_start_quirk => true;

	public override bool is_case_load_quirk => true;

	public override bool is_card_reaction_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CASINO;
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		if (!(_case is CasinoCase @case))
		{
			Debug.LogError($"{quirk_type} is a casino quirk! It is not valid in {_case.case_type}!");
			return _board;
		}
		checkBlock(@case, _board.getRolesInPlay());
		return _board;
	}

	public override void onCaseLoaded(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		if (!(_case is CasinoCase casinoCase))
		{
			Debug.LogError($"{quirk_type} is a casino quirk! It is not valid in {_case.case_type}!");
			return;
		}
		int num = Mathf.Min(casinoCase.left_card.value, 10) + Mathf.Min(casinoCase.left_card.value, 10);
		previous_block = num;
	}

	public override void onCardChange(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCase _case, List<CasinoCard> _discarded, List<CasinoCard> _new_cards, System.Random _rng)
	{
		if (!(_case.left_card == null) && !(_case.right_card == null))
		{
			checkBlock(_case, _board.getRolesInPlay());
		}
	}

	private void checkBlock(CasinoCase _case, Dictionary<int, RoleData> _in_play_roles)
	{
		int num = Mathf.Min(_case.left_card.value, 10) + Mathf.Min(_case.right_card.value, 10);
		if (num != previous_block && _in_play_roles.ContainsKey(previous_block))
		{
			_in_play_roles[previous_block].setCanBeInvestigated("Quirk_DC", _true: true);
			previous_block = -1;
		}
		if (_in_play_roles.ContainsKey(num))
		{
			_in_play_roles[num].setCanBeInvestigated("Quirk_DC", _true: false);
			previous_block = num;
		}
	}
}
