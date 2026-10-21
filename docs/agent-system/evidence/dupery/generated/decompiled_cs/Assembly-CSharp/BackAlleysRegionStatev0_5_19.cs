using System;
using GRGLib.Extensions.Random;
using GRGLib.Generic;
using Save;
using UnityEngine;

public class BackAlleysRegionStatev0_5_19 : RegionStatev0_5_19
{
	public static int max_progress = 100;

	public static int max_reputation = 6;

	public static int starting_health = 6;

	public static int starting_money = 25;

	public int region_progress;

	public int health;

	public int max_health = BackAlleysCase.default_max_health;

	public int money;

	public BackAlleysPouch pouch;

	public override CaseType case_type => CaseType.BACK_ALLEYS;

	public override float region_progress_01 => (float)region_progress / 100f;

	protected override MinMaxFloat start_difficulty
	{
		get
		{
			if (region == Regions.BACK_ALLEYS)
			{
				return new MinMaxFloat(0f, 0.25f);
			}
			throw new ArgumentException($"No starting difficulty set for region {region}! (BackAlleysRegionState.start_difficulty)");
		}
	}

	protected override MinMaxFloat end_difficulty
	{
		get
		{
			if (region == Regions.BACK_ALLEYS)
			{
				return new MinMaxFloat(0.35f, 0.6f);
			}
			throw new ArgumentException($"No ending difficulty set for region {region}! (BackAlleysRegionState.end_difficulty)");
		}
	}

	private MinMaxFloat progress_per_case
	{
		get
		{
			if (region == Regions.BACK_ALLEYS)
			{
				return new MinMaxFloat(10f, 13f);
			}
			throw new ArgumentException($"No progress per case set for region {region}! (BackAlleysRegionState.progress_per_case)");
		}
	}

	private float progress_per_diff
	{
		get
		{
			if (region == Regions.BACK_ALLEYS)
			{
				int num = 18;
				return num;
			}
			throw new ArgumentException($"No progress per difficulty set for region {region}! (BackAlleysRegionState.progress_per_diff)");
		}
	}

	public BackAlleysRegionStatev0_5_19(Regions _region)
		: base(_region)
	{
		region_progress = 0;
		health = starting_health;
		money = starting_money;
		pouch = new BackAlleysPouch(delegate
		{
			Debug.LogError("Trying to use item not in case?");
		}, delegate
		{
			Debug.LogError("Trying to use item not in case?");
		});
	}

	public BackAlleysRegionStatev0_5_19(RegionSaveDatav0_5_19 _save)
		: base(_save)
	{
		try
		{
			BackAlleyRegionUniqueSaveDatav0_5_19 backAlleyRegionUniqueSaveDatav0_5_ = JsonUtility.FromJson<BackAlleyRegionUniqueSaveDatav0_5_19>(_save.data);
			region_progress = backAlleyRegionUniqueSaveDatav0_5_.region_progress;
			health = backAlleyRegionUniqueSaveDatav0_5_.health;
			max_health = BackAlleysCase.default_max_health;
			money = backAlleyRegionUniqueSaveDatav0_5_.money;
			pouch = new BackAlleysPouch(backAlleyRegionUniqueSaveDatav0_5_.pouch, RandomExtensions.freshRandom(), delegate
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
			region_progress = 0;
			health = starting_health;
			max_health = BackAlleysCase.default_max_health;
			money = starting_money;
			pouch = new BackAlleysPouch(delegate
			{
				Debug.LogError("Trying to use item not in case?");
			}, delegate
			{
				Debug.LogError("Trying to use item not in case?");
			});
		}
	}

	private MinMaxFloat getRewardCredits(float _diff)
	{
		return new MinMaxFloat(7f * (1f + _diff * 1.5f), 12f * (1f + _diff));
	}

	public override CaseReward createRewardForCase(float _diff, System.Random _random, bool _is_final_case, CaseBuildData _build_data, int _case_nb)
	{
		return new BackAlleysCaseReward(Mathf.RoundToInt(progress_per_diff * _diff + progress_per_case.get(_random)), Mathf.RoundToInt(getRewardCredits(_diff).get(_random)), _syndicate_clue: false);
	}

	public override bool isFinalCase()
	{
		return region_progress >= max_progress;
	}

	public override bool onCaseSolve(GameState _state, CaseActionPayload _payload)
	{
		if (!(_payload is BackAlleysCaseActionPayload backAlleysCaseActionPayload) || !_state.case_reward.is_some || !(_state.case_reward.value is BackAlleysCaseReward backAlleysCaseReward))
		{
			Debug.LogError("Calling on case solve of the BackAlleyRegion is not allowed when you are not in the Back Alleys region! Please pass in a valid payload &/or reward!");
			return false;
		}
		region_progress = Mathf.Min(region_progress + backAlleysCaseReward.region_progress, max_progress);
		money += backAlleysCaseReward.money_gained;
		pouch = backAlleysCaseActionPayload.pouch;
		health = backAlleysCaseActionPayload.current_health;
		return region_progress >= 100;
	}

	public override void onTutorialSolve()
	{
		base.onTutorialSolve();
		region_progress = 0;
		health = starting_health;
		money = starting_money;
	}

	public override string getUniqueData()
	{
		return JsonUtility.ToJson(new BackAlleyRegionUniqueSaveDatav0_5_19(region_progress, health, money, pouch.toSaveData()));
	}
}
