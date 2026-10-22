using System;
using Save;
using UnityEngine;

namespace GameStats;

public class OfficeCaseStats : CaseStats
{
	public int time_passed;

	public OfficeCaseStats()
	{
	}

	public OfficeCaseStats(CaseStatsSaveData _save)
		: base(_save)
	{
		try
		{
			time_passed = int.Parse(_save.region_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load office stats! ({_save.region_data}) Error: {arg}");
			time_passed = 0;
		}
	}

	protected override void addRegionStats(CaseStats _stats)
	{
		if (!(_stats is OfficeCaseStats officeCaseStats))
		{
			Debug.LogError("Trying to add none-office stats to a OfficeCaseStats class. This is not allowed!");
		}
		else
		{
			time_passed += officeCaseStats.time_passed;
		}
	}

	public override string getRegionSaveData()
	{
		return time_passed.ToString();
	}
}
