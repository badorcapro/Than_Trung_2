using System;
using GRGLib.Generic;
using Save;
using UnityEngine;

public class CasinoRegionStatev0_5_19 : RegionStatev0_5_19
{
	public static int chips_target = 1000;

	public static int starting_chips = 50;

	public int chips;

	public int cases_played;

	public float cost_multi => cases_played switch
	{
		0 => 1f, 
		1 => 1.5f, 
		2 => 2f, 
		3 => 3f, 
		4 => 4f, 
		5 => 5f, 
		6 => 6f, 
		7 => 8f, 
		8 => 10f, 
		9 => 12f, 
		10 => 15f, 
		11 => 18f, 
		12 => 21f, 
		13 => 25f, 
		_ => 25 + (cases_played - 13) * 5, 
	};

	protected override MinMaxFloat start_difficulty => new MinMaxFloat(0.05f, 0.25f);

	protected override MinMaxFloat end_difficulty => new MinMaxFloat(0.4f, 0.6f);

	private MinMaxFloat chips_reward_base => new MinMaxFloat(70f, 115f);

	private MinMaxFloat chips_rewards => chips_reward_base * Mathf.Pow(1.2f, cases_played);

	private MinMaxInt random_chip_reward => new MinMaxInt(0, 10);

	public bool slot_machine_available { get; private set; } = true;

	public override CaseType case_type => CaseType.CASINO;

	public override float region_progress_01 => Mathf.Clamp01((float)chips / (float)chips_target);

	public CasinoRegionStatev0_5_19(Regions _region)
		: base(_region)
	{
		chips = starting_chips;
		cases_played = 0;
	}

	public CasinoRegionStatev0_5_19(RegionSaveDatav0_5_19 _save)
		: base(_save)
	{
		try
		{
			string[] array = _save.data.Split(',');
			chips = int.Parse(array[0]);
			cases_played = int.Parse(array[1]);
			slot_machine_available = array[2] == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"Something went wrong parsing save data! Error:{arg}");
			chips = starting_chips;
			cases_played = 0;
			slot_machine_available = false;
		}
	}

	public override CaseReward createRewardForCase(float _diff, System.Random _random, bool _is_final_case, CaseBuildData _build_data, int _case_nb)
	{
		if (!_is_final_case)
		{
			return new CasinoCaseReward(Mathf.CeilToInt(chips_rewards.estimate(_diff)) + random_chip_reward.get(_random), _syndicate_clue: false);
		}
		return new CasinoCaseReward(0, _syndicate_clue: true);
	}

	public override bool isFinalCase()
	{
		return chips >= chips_target;
	}

	public override bool onCaseSolve(GameState _state, CaseActionPayload _payload)
	{
		if (!(_payload is CasinoCaseActionPayload casinoCaseActionPayload) || !_state.case_reward.is_some || !(_state.case_reward.value is CasinoCaseReward casinoCaseReward))
		{
			Debug.LogError("Calling on case solve of the CasinoRegionState is not allowed when you are not in the casino region! Please pass in a valid payload and/or reward!");
			return false;
		}
		chips = casinoCaseActionPayload.chips + casinoCaseReward.chips_gained;
		cases_played++;
		return chips >= chips_target;
	}

	public override void onTutorialSolve()
	{
		base.onTutorialSolve();
		chips = starting_chips;
		cases_played = 0;
	}

	public override string getUniqueData()
	{
		return string.Format("{0},{1},{2}", chips, cases_played, slot_machine_available ? "t" : "f");
	}

	public void setSlotMachineAvailable()
	{
		slot_machine_available = true;
	}
}
