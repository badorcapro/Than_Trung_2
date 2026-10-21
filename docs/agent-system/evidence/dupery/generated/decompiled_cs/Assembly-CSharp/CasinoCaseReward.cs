using System;
using Save;
using UnityEngine;

public class CasinoCaseReward : CaseReward
{
	public int chips_gained;

	public CasinoCaseReward(int _chips, bool _syndicate_clue)
		: base(_syndicate_clue)
	{
		chips_gained = _chips;
	}

	public CasinoCaseReward(CaseRewardSave _save)
		: base(_save)
	{
		try
		{
			chips_gained = int.Parse(_save.data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"(Casino Case Reward) Something went wrong parsing save data ('{_save.data}')! Error: {arg}");
			chips_gained = 0;
		}
	}

	protected override string getData()
	{
		return chips_gained.ToString();
	}
}
