using System;
using UnityEngine;

namespace Quirks;

public class PublicFavour : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.PUBLIC_FAVOUR;

	protected override string english_name => "Public Favour";

	protected override string english_description => "You regain +1 " + Keywords.REPUTATION.toString() + " from solving a case.";

	public override bool is_case_solve_quirk => true;

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
			clockCaseReward.reputation_gain++;
			return clockCaseReward;
		}
		if (_reward is DocksCaseReward docksCaseReward)
		{
			docksCaseReward.reputation_gain++;
			return docksCaseReward;
		}
		Debug.LogError($"No onCaseSolved function set up for reward type {_reward.GetType()}! {quirk_type}");
		return _reward;
	}
}
