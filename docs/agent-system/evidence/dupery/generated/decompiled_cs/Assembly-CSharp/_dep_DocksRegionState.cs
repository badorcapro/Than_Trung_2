using System;
using Nodes.Logic;
using Save;
using UnityEngine;

public class _dep_DocksRegionState : _dep_RegionState
{
	public static int max_reputation = 6;

	public static int starting_reputation = 5;

	public int reputation;

	public override CaseType case_type => CaseType.DOCKS;

	public _dep_DocksRegionState(RegionDataGraph _graph)
		: base(_graph)
	{
		reputation = starting_reputation;
	}

	public _dep_DocksRegionState(_dep_RegionSaveData _save)
		: base(_save)
	{
		try
		{
			reputation = int.Parse(_save.data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Something went wrong parsing save data! Error:{arg}");
			reputation = starting_reputation;
		}
	}

	public override void onCaseSolve(GameState _state, CaseActionPayload _payload)
	{
		if (!(_payload is DocksCaseActionPayload docksCaseActionPayload) || !_state.case_reward.is_some || !(_state.case_reward.value is DocksCaseReward docksCaseReward))
		{
			Debug.LogError("Calling on case solve of the ClockRegionState is not allowed when you are not in the clock region! Please pass in a valid payload &/or reward!");
		}
		else
		{
			reputation = Mathf.Max(1, Mathf.Min(docksCaseActionPayload.reputation + (base.case_quirks.inPlay(CaseQuirks.PUBLIC_FAVOUR) ? (docksCaseReward.reputation_gain * 2) : docksCaseReward.reputation_gain), max_reputation));
		}
	}

	public override string getUniqueData()
	{
		return reputation.ToString();
	}
}
