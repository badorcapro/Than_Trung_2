using System;
using System.Linq;
using UnityEngine;

namespace Quirks;

public class LoyaltyCard : CaseQuirkData
{
	private const int chips_reward = 20;

	public override CaseQuirks quirk_type => CaseQuirks.LOYALTY_CARD;

	protected override string english_name => "Loyalty Card";

	protected override string english_description => $"Gain {20} {TextHelper.chips_with_link} if all {TextHelper.abilities} are used when solving a {Keywords.CASE.toString()}.";

	public override string description_white => base.description.colourSpriteLink("chip", Color.white);

	public override string credit => "DanielDavidGuy";

	public override bool is_case_solve_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CASINO;
	}

	public override CaseReward onCaseSolved(CaseReward _reward, GameState _state, CaseSnapshot _snapshot, CaseActionPayload _payload, System.Random _rng)
	{
		if (_snapshot.address_occupents.Values.Any((RoleData _r) => _r.getHasAnyAbility() && !_r.getIsAbilityExhausted()))
		{
			return _reward;
		}
		if (!(_reward is CasinoCaseReward casinoCaseReward) || !(_payload is CasinoCaseActionPayload))
		{
			Debug.LogError($"{quirk_type} is a casino quirk! Cannot be applied with {_reward.GetType()} & {_payload.GetType()}!");
			return _reward;
		}
		casinoCaseReward.chips_gained += 20;
		return casinoCaseReward;
	}
}
