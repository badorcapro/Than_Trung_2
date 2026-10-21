using System;
using UnityEngine;

namespace Quirks;

public class HighValueTarget : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.HIGH_VALUE_TARGET;

	protected override string english_name => "High Value Target";

	protected override string english_description => "When you solve a " + Keywords.CASE.toString() + ", gain your highest " + TextHelper.cardsValue + " in " + TextHelper.chips_with_link + ".";

	protected override string english_extra_description => "A " + Keywords.FACE_CARD.toString() + "'s " + TextHelper.value + " is considered to be 10 for this quirk.";

	public override string description_white => base.description.colourSpriteLink("chip", Color.white);

	public override bool is_case_solve_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CASINO;
	}

	public override CaseReward onCaseSolved(CaseReward _reward, GameState _state, CaseSnapshot _snapshot, CaseActionPayload _payload, System.Random _rng)
	{
		if (!(_reward is CasinoCaseReward casinoCaseReward) || !(_payload is CasinoCaseActionPayload casinoCaseActionPayload))
		{
			Debug.LogError($"{quirk_type} is a casino quirk! Cannot be applied with {_reward.GetType()} & {_payload.GetType()}!");
			return _reward;
		}
		casinoCaseReward.chips_gained += Mathf.Min(Mathf.Max(casinoCaseActionPayload.left_card.value, casinoCaseActionPayload.right_card.value), 10);
		return casinoCaseReward;
	}
}
