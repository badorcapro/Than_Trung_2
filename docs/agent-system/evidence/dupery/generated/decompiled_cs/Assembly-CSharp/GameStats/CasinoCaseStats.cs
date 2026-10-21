using System;
using Save;
using UnityEngine;

namespace GameStats;

public class CasinoCaseStats : CaseStats
{
	public int chips_spent;

	public int chips_gained;

	public CasinoCaseStats()
	{
	}

	public CasinoCaseStats(CaseStatsSaveData _save)
		: base(_save)
	{
		try
		{
			string[] array = _save.region_data.Split(',');
			chips_spent = int.Parse(array[0]);
			chips_gained = int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load Casino stats! ({_save.region_data}) Error: {arg}");
			chips_spent = 0;
			chips_gained = 0;
		}
	}

	protected override void addRegionStats(CaseStats _stats)
	{
		if (!(_stats is CasinoCaseStats casinoCaseStats))
		{
			Debug.LogError("Trying to add none-office stats to a OfficeCaseStats class. This is not allowed!");
			return;
		}
		chips_spent += casinoCaseStats.chips_spent;
		chips_gained += casinoCaseStats.chips_gained;
	}

	public override string getRegionSaveData()
	{
		return $"{chips_spent},{chips_gained}";
	}
}
