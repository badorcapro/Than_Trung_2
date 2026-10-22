using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Serializable;
using Save;
using UnityEngine;

namespace GameStats;

public class BackAlleyCaseStats : CaseStats
{
	public Dictionary<BackAlleysItemType, int> items_used = new Dictionary<BackAlleysItemType, int>();

	public BackAlleyCaseStats()
	{
	}

	public BackAlleyCaseStats(CaseStatsSaveData _save)
		: base(_save)
	{
		try
		{
			items_used = JsonUtility.FromJson<SerializableDictionary<BackAlleysItemType, int>>(_save.region_data).unserialize();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load Back Alleys stats! ({_save.region_data}) Error: {arg}");
			items_used = new Dictionary<BackAlleysItemType, int>();
		}
	}

	protected override void addRegionStats(CaseStats _stats)
	{
		if (!(_stats is BackAlleyCaseStats backAlleyCaseStats))
		{
			Debug.LogError("Trying to add none-office stats to a OfficeCaseStats class. This is not allowed!");
		}
		else
		{
			items_used.increaseOrCreateRange(backAlleyCaseStats.items_used);
		}
	}

	public override string getRegionSaveData()
	{
		return JsonUtility.ToJson(items_used.toSerializableDictionary());
	}
}
