using System;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using GRGLib.Maybe;
using GRGLib.Serializable;
using Leads;
using Save;
using UnityEngine;
using Visual;

namespace AlternateModes;

public class SurvivalAMD : AlternateModeData, IMessWithCases, IModeWithData
{
	private int solved_cases;

	public override AlternateModeTypes mode_type => AlternateModeTypes.SURVIVAL;

	protected override string english_name => "Endless Survival";

	protected override string english_description => "How many " + TextHelper.cases + " can you solve without ever regaining " + Keywords.REPUTATION.toString() + ".";

	public SurvivalAMD()
	{
		solved_cases = 0;
	}

	public SurvivalAMD(string _save)
	{
		try
		{
			solved_cases = int.Parse(_save);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed {mode_type} load!\nSave: {_save}\nError: {arg}");
			solved_cases = 0;
		}
	}

	public override string getExtraDescription(Regions _region, AlternateModeStatsData _stats)
	{
		SerializableDictionary<Regions, int> serializableDictionary = JsonUtility.FromJson<SerializableDictionary<Regions, int>>(_stats.data);
		if (!serializableDictionary.ContainsKey(_region))
		{
			return "";
		}
		return highscoreLocalised(casesSolvedLocalised(serializableDictionary[_region].ToString()));
	}

	public override void startMode(Regions _region, RegionsSO _regions_data, RegionProgressionSaveData _progression, System.Random _rng)
	{
		GameHandler.instance.startMode(this, createBasicLead(_region, _regions_data, _progression.using_tier, new Vector2Int(4, 4), new MinMaxFloat(0f, 1f), 12, _rng), new Maybe<LeadProgressionManager>());
	}

	public override void onModeCompleted(GameState _state, bool _success)
	{
		if (!_state.current_lead.is_some)
		{
			return;
		}
		Regions region = _state.current_lead.value.case_type.fromType();
		GameHandler.StatsData.onAltModeFinished(mode_type, Regions.CASINO, delegate(string _c)
		{
			SerializableDictionary<Regions, int> serializableDictionary = ((_c == "") ? new SerializableDictionary<Regions, int>() : JsonUtility.FromJson<SerializableDictionary<Regions, int>>(_c));
			int orDefault = serializableDictionary.getOrDefault(region, 0);
			if (solved_cases > orDefault)
			{
				serializableDictionary[region] = solved_cases;
				return JsonUtility.ToJson(serializableDictionary);
			}
			return _c;
		});
	}

	public void onCaseStart(Case _case, GameVisualManager _manager)
	{
	}

	public void onInteraction(Case _case, GameVisualManager _world)
	{
	}

	public void onCaseEnd(Case _case, CaseSnapshot _snap, bool _solved)
	{
		solved_cases += (_solved ? 1 : 0);
	}

	public string toSave()
	{
		return solved_cases.ToString();
	}
}
