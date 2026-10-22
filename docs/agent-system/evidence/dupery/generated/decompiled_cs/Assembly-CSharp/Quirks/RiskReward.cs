using System;
using UnityEngine;

namespace Quirks;

public class RiskReward : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.RISK_REWARD;

	protected override string english_name => "Risk Reward";

	protected override string english_description => "Base " + TextHelper.chips_with_link + " costs and rewards are doubled.";

	public override string description_white => base.description.colourSpriteLink("chip", Color.white);

	public override bool is_chips_spent_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CASINO;
	}

	public override void onChipsSpent(CasinoCase _case, int _chips_diff, System.Random _rng)
	{
		if (_chips_diff > 0)
		{
			_case.gainChipsSilent(_chips_diff);
		}
		else
		{
			_case.spendChipsSilent(-_chips_diff);
		}
	}
}
