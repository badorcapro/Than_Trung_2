using System;
using UnityEngine;

namespace Quirks;

public class PublicUnrest : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.PUBLIC_UNREST;

	protected override string english_name => "Public Unrest";

	protected override string english_description => "You no longer regain " + Keywords.REPUTATION.toString() + " when solving a " + Keywords.CASE.toString() + ".";

	public override bool is_case_solve_quirk => true;

	public override int execution_order => -1;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type switch
		{
			CaseType.CLOCK => true, 
			CaseType.DOCKS => true, 
			_ => false, 
		};
	}

	public override CaseReward onCaseSolved(CaseReward _reward, GameState _state, CaseSnapshot _snap, CaseActionPayload _payload, System.Random _rng)
	{
		if (_reward is ClockCaseReward clockCaseReward)
		{
			clockCaseReward.reputation_gain = 0;
			return clockCaseReward;
		}
		if (_reward is DocksCaseReward docksCaseReward)
		{
			docksCaseReward.reputation_gain = 0;
			return docksCaseReward;
		}
		Debug.LogError($"No onCaseSolved function set up for reward type {_reward.GetType()}! {quirk_type}");
		return _reward;
	}
}
