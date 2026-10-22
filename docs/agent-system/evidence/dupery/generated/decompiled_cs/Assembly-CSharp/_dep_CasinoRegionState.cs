using System;
using Nodes.Logic;
using Save;
using UnityEngine;

public class _dep_CasinoRegionState : _dep_RegionState
{
	public static int starting_chips = 50;

	public int chips;

	public override CaseType case_type => CaseType.CASINO;

	public _dep_CasinoRegionState(RegionDataGraph _graph)
		: base(_graph)
	{
		chips = starting_chips;
	}

	public _dep_CasinoRegionState(_dep_RegionSaveData _save)
		: base(_save)
	{
		try
		{
			chips = int.Parse(_save.data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Something went wrong parsing save data! Error:{arg}");
			chips = starting_chips;
		}
	}

	public override void onCaseSolve(GameState _state, CaseActionPayload _payload)
	{
		if (!(_payload is CasinoCaseActionPayload casinoCaseActionPayload) || !_state.case_reward.is_some || !(_state.case_reward.value is CasinoCaseReward casinoCaseReward))
		{
			Debug.LogError("Calling on case solve of the ClockRegionState is not allowed when you are not in the clock region! Please pass in a valid payload &/or reward!");
		}
		else
		{
			chips = casinoCaseActionPayload.chips + casinoCaseReward.chips_gained;
		}
	}

	public override string getUniqueData()
	{
		return chips.ToString();
	}
}
