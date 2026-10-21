using System;
using GRGLib.Generic;
using Save;
using UnityEngine;

public class DocksRegionStatev0_5_19 : RegionStatev0_5_19
{
	public static int max_progress = 100;

	public static int max_reputation = 6;

	public static int starting_reputation = 5;

	public int region_progress;

	public int reputation;

	public override CaseType case_type => CaseType.DOCKS;

	public override float region_progress_01 => (float)region_progress / 100f;

	protected override MinMaxFloat start_difficulty
	{
		get
		{
			if (region == Regions.DOCKS)
			{
				return new MinMaxFloat(0f, 0.25f);
			}
			throw new ArgumentException($"No starting difficulty set for region {region}! (DocksRegionState.start_difficulty)");
		}
	}

	protected override MinMaxFloat end_difficulty
	{
		get
		{
			if (region == Regions.DOCKS)
			{
				return new MinMaxFloat(0.35f, 0.6f);
			}
			throw new ArgumentException($"No ending difficulty set for region {region}! (DocksRegionState.end_difficulty)");
		}
	}

	public DocksRegionStatev0_5_19(Regions _region)
		: base(_region)
	{
		region_progress = 0;
		reputation = starting_reputation;
	}

	public DocksRegionStatev0_5_19(RegionSaveDatav0_5_19 _save)
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

	public override CaseReward createRewardForCase(float _diff, System.Random _random, bool _is_final_case, CaseBuildData _build_data, int _case_option)
	{
		return new DocksCaseReward(_random.Next(5 + Mathf.RoundToInt(_diff * 2f), 6 + Mathf.RoundToInt(_diff * 4f)), (_case_option != 2 || reputation > 2 || _build_data.buildCase().pregameSnap().classification_ratio[RoleClassifications.TRAITOR] != 1) ? 1 : 2, _syndicate_clue: false);
	}

	public override bool isFinalCase()
	{
		return region_progress >= max_progress;
	}

	public override bool onCaseSolve(GameState _state, CaseActionPayload _payload)
	{
		if (!(_payload is DocksCaseActionPayload docksCaseActionPayload) || !_state.case_reward.is_some || !(_state.case_reward.value is DocksCaseReward docksCaseReward))
		{
			Debug.LogError("Calling on case solve of the DocksRegionState is not allowed when you are not in the Docks region! Please pass in a valid payload &/or reward!");
			return false;
		}
		region_progress = Mathf.Min(region_progress + docksCaseReward.region_progress_per_arrest * docksCaseActionPayload.correct_arrests, max_progress);
		reputation = Mathf.Max(1, Mathf.Min(docksCaseActionPayload.reputation + (base.case_quirks.inPlay(CaseQuirks.PUBLIC_FAVOUR) ? (docksCaseReward.reputation_gain * 2) : docksCaseReward.reputation_gain), max_reputation));
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
