using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Serializable;
using Save;
using UnityEngine;

namespace GameStats;

public class DocksCaseStats : CaseStats
{
	public int fuel_used;

	public Dictionary<Roles, int> evil_uncaptured = new Dictionary<Roles, int>();

	public DocksCaseStats()
	{
	}

	public DocksCaseStats(int _fuel, List<Roles> _uncaptured_evil)
	{
		fuel_used = _fuel;
		evil_uncaptured = _uncaptured_evil.Aggregate(new Dictionary<Roles, int>(), (Dictionary<Roles, int> _a, Roles _r) => _a.addTo(_r, 1));
	}

	public DocksCaseStats(CaseStatsSaveData _save)
		: base(_save)
	{
		try
		{
			string[] array = _save.region_data.Split('#');
			fuel_used = int.Parse(array[0]);
			evil_uncaptured = JsonUtility.FromJson<SerializableDictionary<Roles, int>>(array[1]).unserialize();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load docks stats! ({_save.region_data}) Error: {arg}");
			fuel_used = 0;
			evil_uncaptured = new Dictionary<Roles, int>();
		}
	}

	protected override void addRegionStats(CaseStats _stats)
	{
		if (!(_stats is DocksCaseStats docksCaseStats))
		{
			Debug.LogError("Trying to add none-office stats to a OfficeCaseStats class. This is not allowed!");
			return;
		}
		fuel_used += docksCaseStats.fuel_used;
		evil_uncaptured.increaseOrCreateRange(docksCaseStats.evil_uncaptured);
	}

	public override string getRegionSaveData()
	{
		return $"{fuel_used}#{JsonUtility.ToJson(evil_uncaptured.toSerializableDictionary())}";
	}
}
