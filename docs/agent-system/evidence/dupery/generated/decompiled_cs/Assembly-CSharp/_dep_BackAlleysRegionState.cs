using System;
using GRGLib.Extensions.Random;
using Nodes.Logic;
using Save;
using UnityEngine;

public class _dep_BackAlleysRegionState : _dep_RegionState
{
	public static int starting_health = 6;

	public static int max_health = 6;

	public static int starting_credits = 20;

	public int health;

	public int credits;

	public BackAlleysPouch pouch;

	public override CaseType case_type => CaseType.BACK_ALLEYS;

	public _dep_BackAlleysRegionState(RegionDataGraph _graph)
		: base(_graph)
	{
		health = starting_health;
		credits = starting_credits;
	}

	public _dep_BackAlleysRegionState(_dep_RegionSaveData _save)
		: base(_save)
	{
		try
		{
			BackAlleyRegionUniqueSaveData backAlleyRegionUniqueSaveData = JsonUtility.FromJson<BackAlleyRegionUniqueSaveData>(_save.data);
			health = backAlleyRegionUniqueSaveData.health;
			max_health = BackAlleysCase.default_max_health;
			credits = backAlleyRegionUniqueSaveData.credits;
			pouch = new BackAlleysPouch(backAlleyRegionUniqueSaveData.pouch, RandomExtensions.freshRandom(), delegate
			{
				Debug.LogError("Trying to use item not in case?");
			}, delegate
			{
				Debug.LogError("Trying to use item not in case?");
			});
		}
		catch (Exception arg)
		{
			Debug.LogError($"Something went wrong parsing save data!\n({_save.data})\nError:{arg}");
			health = starting_health;
			max_health = BackAlleysCase.default_max_health;
			credits = starting_credits;
			pouch = new BackAlleysPouch(delegate
			{
				Debug.LogError("Trying to use item not in case?");
			}, delegate
			{
				Debug.LogError("Trying to use item not in case?");
			});
		}
	}

	public override void onCaseSolve(GameState _state, CaseActionPayload _payload)
	{
		if (!(_payload is BackAlleysCaseActionPayload backAlleysCaseActionPayload) || !_state.case_reward.is_some || !(_state.case_reward.value is BackAlleysCaseReward backAlleysCaseReward))
		{
			Debug.LogError("Calling on case solve of the ClockRegionState is not allowed when you are not in the clock region! Please pass in a valid payload &/or reward!");
			return;
		}
		health = backAlleysCaseActionPayload.current_health;
		credits += backAlleysCaseReward.money_gained;
	}

	public override string getUniqueData()
	{
		return JsonUtility.ToJson(new BackAlleyRegionUniqueSaveData(health, credits, pouch.toSaveData()));
	}
}
