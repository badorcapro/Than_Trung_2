using System;

namespace Quirks;

public class SwiftJustice : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.SWIFT_JUSTICE;

	protected override string english_name => "Swift Justice";

	protected override string english_description => "You regain an additional " + Keywords.REPUTATION.toString() + " if you solve a case in under 12 hours.";

	public override bool is_case_solve_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		if (_case_type == CaseType.CLOCK)
		{
			return true;
		}
		return false;
	}

	public override CaseReward onCaseSolved(CaseReward _reward, GameState _state, CaseSnapshot _snap, CaseActionPayload _payload, Random _rng)
	{
		if (_reward is ClockCaseReward clockCaseReward && _payload is ClockCaseActionPayload { hour_passed: <12 })
		{
			clockCaseReward.reputation_gain++;
			return clockCaseReward;
		}
		return _reward;
	}
}
