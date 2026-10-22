using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Serializable;
using Save;
using UnityEngine;

namespace GameStats;

public class CombinedCaseStats : CaseStats
{
	public int time_passed;

	public int fuel_used;

	public Dictionary<Roles, int> evil_uncaptured = new Dictionary<Roles, int>();

	public int chips_spent;

	public int chips_gained;

	public Dictionary<BackAlleysItemType, int> items_used = new Dictionary<BackAlleysItemType, int>();

	public CombinedCaseStats()
	{
	}

	public CombinedCaseStats(CaseStatsSaveData _save)
		: base(_save)
	{
		try
		{
			string[] array = _save.region_data.Split('#');
			time_passed = int.Parse(array[0]);
			fuel_used = int.Parse(array[1]);
			evil_uncaptured = JsonUtility.FromJson<SerializableDictionary<Roles, int>>(array[2]).unserialize();
			chips_spent = int.Parse(array[3]);
			chips_gained = int.Parse(array[4]);
			items_used = JsonUtility.FromJson<SerializableDictionary<BackAlleysItemType, int>>(array[5]).unserialize();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load office stats! ({_save.region_data}) Error: {arg}");
		}
	}

	protected override void addRegionStats(CaseStats _stats)
	{
		if (_stats is OfficeCaseStats officeCaseStats)
		{
			time_passed += officeCaseStats.time_passed;
		}
		else if (_stats is DocksCaseStats docksCaseStats)
		{
			fuel_used += docksCaseStats.fuel_used;
			evil_uncaptured.increaseOrCreateRange(docksCaseStats.evil_uncaptured);
		}
		else if (_stats is CasinoCaseStats casinoCaseStats)
		{
			chips_spent += casinoCaseStats.chips_spent;
			chips_gained += casinoCaseStats.chips_gained;
		}
		else if (_stats is BackAlleyCaseStats backAlleyCaseStats)
		{
			items_used.increaseOrCreateRange(backAlleyCaseStats.items_used);
		}
		else if (_stats is CombinedCaseStats combinedCaseStats)
		{
			time_passed += combinedCaseStats.time_passed;
			fuel_used += combinedCaseStats.fuel_used;
			evil_uncaptured.increaseOrCreateRange(combinedCaseStats.evil_uncaptured);
			chips_spent += combinedCaseStats.chips_spent;
			chips_gained += combinedCaseStats.chips_gained;
			items_used.increaseOrCreateRange(combinedCaseStats.items_used);
		}
		else
		{
			Debug.LogError("Couldnt add region stats for combined stats as case stats is not of an expected class!");
		}
	}

	public override string getRegionSaveData()
	{
		return $"{time_passed}#{fuel_used}#{JsonUtility.ToJson(evil_uncaptured.toSerializableDictionary())}#{chips_spent}#{chips_gained}#{JsonUtility.ToJson(items_used.toSerializableDictionary())}";
	}
}
