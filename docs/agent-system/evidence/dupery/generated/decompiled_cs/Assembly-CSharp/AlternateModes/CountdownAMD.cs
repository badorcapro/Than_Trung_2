using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Generic;
using GRGLib.Maybe;
using Leads;
using Save;
using UnityEngine;
using Visual;

namespace AlternateModes;

public class CountdownAMD : AlternateModeData, IMessWithCases, IModeWithData
{
	private const int starting_hours = 240;

	private int starting_case_hours;

	private int hours_remaining;

	private int evils_arrested;

	private int reputation;

	public override AlternateModeTypes mode_type => AlternateModeTypes.COUNTDOWN;

	protected override string english_name => "Countdown";

	protected override string english_description => $"How many {TextHelper.evilRoles} can you {Keywords.ARREST.toString()} or {Keywords.KILL.toString()} in {240} hours?";

	public CountdownAMD()
	{
		starting_case_hours = 240;
		hours_remaining = 240;
		evils_arrested = 0;
	}

	public CountdownAMD(string _save)
	{
		try
		{
			string[] array = _save.Split(',');
			hours_remaining = int.Parse(array[0]);
			starting_case_hours = int.Parse(array[1]);
			evils_arrested = int.Parse(array[2]);
			reputation = int.Parse(array[3]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading {mode_type} failed!\nSave: {_save}\nError: {arg}");
			hours_remaining = 240;
			starting_case_hours = 240;
			evils_arrested = 0;
			reputation = 5;
		}
	}

	public override string getExtraDescription(Regions _region, AlternateModeStatsData _stats)
	{
		if (_stats.data == "")
		{
			return "";
		}
		return highscoreLocalised(arrestedLocalised(int.Parse(_stats.data).ToString()));
	}

	public override List<Regions> getAvailableRegions()
	{
		return new List<Regions> { Regions.OFFICE };
	}

	public override void startMode(Regions _region, RegionsSO _regions_data, RegionProgressionSaveData _progression, System.Random _rng)
	{
		Lead lead = createBasicLead(Regions.OFFICE, _regions_data, _progression.using_tier, new Vector2Int(4, 4), new MinMaxFloat(0.2f, 1f), 10, _rng);
		GameHandler.instance.startMode(this, lead, new Maybe<LeadProgressionManager>());
	}

	public override void onModeCompleted(GameState _state, bool _success)
	{
		GameHandler.StatsData.onAltModeFinished(mode_type, Regions.OFFICE, delegate(string _c)
		{
			if (!int.TryParse(_c, out var result))
			{
				return evils_arrested.ToString();
			}
			return (evils_arrested > result) ? evils_arrested.ToString() : _c;
		});
	}

	public void onCaseStart(Case _case, GameVisualManager _world)
	{
		starting_case_hours = hours_remaining;
	}

	public void onInteraction(Case _case, GameVisualManager _world)
	{
		if (!(_case is ClockCase clockCase))
		{
			Debug.LogError($"Countdown Alternate Mode requires clock cases. Renewing board of a {_case.case_type} case is not allowed!");
			return;
		}
		hours_remaining = starting_case_hours - clockCase.getTrueHoursPassed();
		if (hours_remaining <= 0)
		{
			clockCase.setReputationExternally(0);
		}
	}

	public void onCaseEnd(Case _case, CaseSnapshot _snap, bool _solved)
	{
		if (!(_case is ClockCase clockCase))
		{
			Debug.LogError($"Countdown Alternate Mode requires clock cases. Ending a {_case.case_type} case is not allowed!");
			return;
		}
		evils_arrested += _snap.board.getAllArrestedOrDeadRoles().Count((RoleData _r) => _r.getTrueAlignment() == Alignments.EVIL);
		reputation = clockCase.reputation;
	}

	public string toSave()
	{
		return $"{hours_remaining},{starting_case_hours},{evils_arrested},{reputation}";
	}
}
