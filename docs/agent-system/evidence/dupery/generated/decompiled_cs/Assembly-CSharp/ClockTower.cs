using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLib.Serializable;
using Save;
using UnityEngine;

public class ClockTower : ClockLocationData
{
	public enum ClockTowerRingAttribution
	{
		CLOCKTOWER,
		GARGOYLE,
		BELFRY,
		FEARMONGER
	}

	[Serializable]
	private struct ClockTowerSaveStruct
	{
		public List<STupple<int, ClockTowerRingAttribution>> scheduled_rings;

		public List<int> recorded_rings;

		public ClockTowerSaveStruct(List<(int, ClockTowerRingAttribution)> _schedualed_rings, List<int> _recorded_rings)
		{
			scheduled_rings = _schedualed_rings.Select(((int, ClockTowerRingAttribution) _e) => _e.toSTupple()).ToList();
			recorded_rings = _recorded_rings;
		}
	}

	private ClockTowerSaveStruct clocktower_data;

	public override LocationTypes location_type => LocationTypes.CLOCK_TOWER;

	protected override string english_name => "Clock Tower";

	protected override string english_description => "<i>\"One day they'll get it to ring at the right time...\"</i>";

	public List<STupple<int, ClockTowerRingAttribution>> scheduled_rings => clocktower_data.scheduled_rings;

	public List<int> recorded_rings => clocktower_data.recorded_rings;

	public ClockTower(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
		clocktower_data = new ClockTowerSaveStruct(new List<(int, ClockTowerRingAttribution)>().add((_random.Next(1, 24), ClockTowerRingAttribution.CLOCKTOWER)), new List<int>());
	}

	public ClockTower(LocationDataSave _save, System.Random _random)
		: base(_save, _random)
	{
		try
		{
			clocktower_data = JsonUtility.FromJson<ClockTowerSaveStruct>(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {location_type}!\nData: {_save.unique_data}\nError: {arg}");
			clocktower_data = new ClockTowerSaveStruct(new List<(int, ClockTowerRingAttribution)>(), new List<int>());
		}
	}

	public ClockTower(System.Random _random, Vector2Int _board_position, List<(int, ClockTowerRingAttribution)> _ring_times, List<int> _recorded_rings)
		: base(_random, _board_position)
	{
		clocktower_data = new ClockTowerSaveStruct(_ring_times, _recorded_rings);
	}

	public void setScheduledRingTimes(List<(int, ClockTowerRingAttribution)> _ring_times, bool _sort = false)
	{
		clocktower_data.scheduled_rings = _ring_times.Select(((int, ClockTowerRingAttribution) _e) => _e.toSTupple()).ToList();
		if (_sort)
		{
			clocktower_data.scheduled_rings.sort((STupple<int, ClockTowerRingAttribution> _a, STupple<int, ClockTowerRingAttribution> _b) => _a.Item1.CompareTo(_a.Item2));
		}
	}

	public void addNewScheduledRingTime(int _new_time, ClockTowerRingAttribution _source)
	{
		clocktower_data.scheduled_rings.Add(new STupple<int, ClockTowerRingAttribution>(_new_time, _source));
		clocktower_data.scheduled_rings.sort((STupple<int, ClockTowerRingAttribution> _a, STupple<int, ClockTowerRingAttribution> _b) => _a.Item1.CompareTo(_b.Item1));
	}

	public void ringNow(int _time, Case _ref)
	{
		doRing(_time, _ref);
	}

	private void doRing(int _time, Case _ref)
	{
		if (!clocktower_data.recorded_rings.Contains(_time))
		{
			clocktower_data.recorded_rings.Add(_time);
			_ref.triggerLocation(this);
		}
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassed(Case _case_ref, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _new_time)
	{
		while (scheduled_rings.Count > 0 && _new_time >= scheduled_rings[0].Item1)
		{
			doRing(scheduled_rings[0].Item1, _case_ref);
			scheduled_rings.removeAt(0);
		}
		return base.onTimePassed(_case_ref, _board, _new_time);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundAwakeAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (!_board.getRolesInPlayOfClass(RoleClassifications.TRAITOR).Any((RoleData _t) => _t.role == Roles.FEARMONGER))
		{
			return _board;
		}
		scheduled_rings.removeAll((STupple<int, ClockTowerRingAttribution> _e) => _e.Item2 == ClockTowerRingAttribution.CLOCKTOWER);
		for (int i = 0; i < Fearmonger.total_ring_times; i++)
		{
			addNewScheduledRingTime((i + 1) * Fearmonger.ring_gaps, ClockTowerRingAttribution.FEARMONGER);
		}
		return base.onRoundAwakeAction(_board, _payload, _suspects);
	}

	protected override string getUniqueSaveData()
	{
		return JsonUtility.ToJson(clocktower_data);
	}

	public override bool isOfRegion(Regions _region)
	{
		return _region switch
		{
			Regions.OFFICE => true, 
			Regions.DEMO => true, 
			Regions.QUIRK_I => true, 
			Regions.QUIRK_II => true, 
			Regions.QUIRK_III => true, 
			_ => false, 
		};
	}
}
