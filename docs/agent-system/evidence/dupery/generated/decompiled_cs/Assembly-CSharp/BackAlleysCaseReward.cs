using System;
using Save;
using UnityEngine;

public class BackAlleysCaseReward : CaseReward
{
	public int region_progress;

	public int money_gained;

	public BackAlleysCaseReward(int _region_prog, int _money_gain, bool _syndicate_clue)
		: base(_syndicate_clue)
	{
		region_progress = _region_prog;
		money_gained = _money_gain;
	}

	public BackAlleysCaseReward(CaseRewardSave _save)
		: base(_save)
	{
		try
		{
			string[] array = _save.data.Split(',');
			region_progress = int.Parse(array[0]);
			money_gained = int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"(Back Alley Case Reward) Something went wrong parsing save data ('{_save.data}')! Error: {arg}");
			region_progress = 0;
			money_gained = 1;
		}
	}

	protected override string getData()
	{
		return $"{region_progress},{money_gained}";
	}
}
