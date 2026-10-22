using System;
using GRGLib.Generic;
using Save;
using UnityEngine;

public class ClockRegionStatev0_5_19 : RegionStatev0_5_19
{
	public static int max_progress = 100;

	public static int max_reputation = 6;

	public static int starting_reputation = 5;

	public int region_progress;

	public int reputation;

	public override CaseType case_type => CaseType.CLOCK;

	public override float region_progress_01 => (float)region_progress / 100f;

	protected override MinMaxFloat start_difficulty => region switch
	{
		Regions.DEMO => new MinMaxFloat(0f, 0.15f), 
		Regions.QUIRK_I => new MinMaxFloat(0f, 0.2f), 
		Regions.QUIRK_II => new MinMaxFloat(0f, 0.25f), 
		Regions.QUIRK_III => new MinMaxFloat(0.1f, 0.3f), 
		Regions.OFFICE => new MinMaxFloat(0f, 0.15f), 
		_ => throw new ArgumentException($"No starting difficulty set for region {region}! (ClockRegionState.start_difficulty)"), 
	};

	protected override MinMaxFloat end_difficulty => region switch
	{
		Regions.DEMO => new MinMaxFloat(0.3f, 0.45f), 
		Regions.QUIRK_I => new MinMaxFloat(0.3f, 0.45f), 
		Regions.QUIRK_II => new MinMaxFloat(0.35f, 0.55f), 
		Regions.QUIRK_III => new MinMaxFloat(0.4f, 0.6f), 
		Regions.OFFICE => new MinMaxFloat(0.3f, 0.45f), 
		_ => throw new ArgumentException($"No ending difficulty set for region {region}! (ClockRegionState.end_difficulty)"), 
	};

	private MinMaxFloat progress_per_case => region switch
	{
		Regions.DEMO => new MinMaxFloat(12f, 15f), 
		Regions.QUIRK_I => new MinMaxFloat(10f, 13f), 
		Regions.QUIRK_II => new MinMaxFloat(8f, 10f), 
		Regions.QUIRK_III => new MinMaxFloat(5f, 8f), 
		Regions.OFFICE => new MinMaxFloat(12f, 15f), 
		_ => throw new ArgumentException($"No progress per case set for region {region}! (ClockRegionState.progress_per_case)"), 
	};

	private float progress_per_diff => region switch
	{
		Regions.DEMO => 17, 
		Regions.QUIRK_I => 18, 
		Regions.QUIRK_II => 20, 
		Regions.QUIRK_III => 22, 
		Regions.OFFICE => 17, 
		_ => throw new ArgumentException($"No progress per difficulty set for region {region}! (ClockRegionState.progress_per_diff)"), 
	};

	public ClockRegionStatev0_5_19(Regions _region)
		: base(_region)
	{
		region_progress = 0;
		reputation = starting_reputation;
	}

	public ClockRegionStatev0_5_19(RegionSaveDatav0_5_19 _save)
		: base(_save)
	{
		try
		{
			string[] array = _save.data.Split(',');
			region_progress = int.Parse(array[0]);
			reputation = int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Something went wrong parsing save data! Error:{arg}");
			region_progress = 0;
			reputation = starting_reputation;
		}
	}

	public override CaseReward createRewardForCase(float _diff, System.Random _random, bool _is_final_case, CaseBuildData _case_build, int _case_option)
	{
		if (!_is_final_case)
		{
			return new ClockCaseReward(Mathf.RoundToInt(progress_per_diff * _diff + progress_per_case.get(_random)), (_case_option != 2 || reputation > 2 || _case_build.buildCase().pregameSnap().classification_ratio[RoleClassifications.TRAITOR] != 1) ? 1 : 2, _syndicate_clue: false);
		}
		return new ClockCaseReward(0, 0, _syndicate_clue: true);
	}

	public override bool isFinalCase()
	{
		return region_progress >= max_progress;
	}

	public override bool onCaseSolve(GameState _state, CaseActionPayload _payload)
	{
		if (!(_payload is ClockCaseActionPayload clockCaseActionPayload) || !_state.case_reward.is_some || !(_state.case_reward.value is ClockCaseReward clockCaseReward))
		{
			Debug.LogError("Calling on case solve of the ClockRegionState is not allowed when you are not in the clock region! Please pass in a valid payload &/or reward!");
			return false;
		}
		region_progress = Mathf.Min(region_progress + clockCaseReward.region_progress, max_progress);
		reputation = Mathf.Max(1, Mathf.Min(clockCaseActionPayload.reputation + (base.case_quirks.inPlay(CaseQuirks.PUBLIC_FAVOUR) ? (clockCaseReward.reputation_gain * 2) : clockCaseReward.reputation_gain), max_reputation));
		return region_progress >= 100;
	}

	public override void onTutorialSolve()
	{
		base.onTutorialSolve();
		region_progress = 0;
		reputation = 5;
	}

	public override string getUniqueData()
	{
		return $"{region_progress},{reputation}";
	}
}
