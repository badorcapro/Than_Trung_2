using System;
using Save;
using UnityEngine;

public class DocksCaseReward : CaseReward
{
	public int region_progress_per_arrest;

	public int reputation_gain;

	public DocksCaseReward(int _region_prog, int _rep_gain, bool _syndicate_clue)
		: base(_syndicate_clue)
	{
		region_progress_per_arrest = _region_prog;
		reputation_gain = _rep_gain;
	}

	public DocksCaseReward(CaseRewardSave _save)
		: base(_save)
	{
		try
		{
			string[] array = _save.data.Split(',');
			region_progress_per_arrest = int.Parse(array[0]);
			reputation_gain = int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"(Docks Case Reward) Something went wrong parsing save data ('{_save.data}')! Error: {arg}");
			region_progress_per_arrest = 0;
			reputation_gain = 1;
		}
	}

	protected override string getData()
	{
		return $"{region_progress_per_arrest},{reputation_gain}";
	}
}
