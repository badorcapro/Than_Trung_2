using System;
using Save;
using UnityEngine;

public class ClockCaseReward : CaseReward
{
	public int region_progress;

	public int reputation_gain;

	public ClockCaseReward(int _region_progress, int _reputation_gain, bool _syndicate_clue)
		: base(_syndicate_clue)
	{
		region_progress = _region_progress;
		reputation_gain = _reputation_gain;
	}

	public ClockCaseReward(CaseRewardSave _save)
		: base(_save)
	{
		try
		{
			string[] array = _save.data.Split(',');
			region_progress = int.Parse(array[0]);
			reputation_gain = int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"(Clock Case Reward) Something went wrong parsing save data ('{_save.data}')! Error: {arg}");
			region_progress = 0;
			reputation_gain = 1;
		}
	}

	protected override string getData()
	{
		return $"{region_progress},{reputation_gain}";
	}
}
