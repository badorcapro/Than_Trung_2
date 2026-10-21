using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using GRGLib.Serializable;
using Save;
using UnityEngine;

public class ClockMaker : ClockRoleData
{
	private int ring_time = -1;

	public override Roles role => Roles.CLOCK_MAKER;

	public override string english_name => "Clock Maker";

	public override string english_description => TextHelper.whenInvestigated + ", I " + Keywords.ANNOUNCE.toString() + " one time the " + LocationTypes.CLOCK_TOWER.toString() + " will ring. I add a " + LocationTypes.CLOCK_TOWER.toString() + " on the " + Keywords.BOARD.toString() + " when I am " + Keywords.SUSPECTED.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, TextHelper.iAmSelfConfirm));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a time during which the " + LocationTypes.CLOCK_TOWER.toString() + " will not ring."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public ClockMaker(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public ClockMaker(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			ring_time = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nData: {_save.unique_data}\nError: {arg}");
			ring_time = -1;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.SELF_CONFIRM, new SuspectLocationGC(LocationTypes.CLOCK_TOWER));
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return _occupent.maybe_b.value.location_type == LocationTypes.CLOCK_TOWER;
		}
		return false;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.has_bad_info)
		{
			return _board;
		}
		Dictionary<LocationTypes, LocationData> locationsInPlay = _board.getLocationsInPlay();
		if (!locationsInPlay.ContainsKey(LocationTypes.CLOCK_TOWER))
		{
			Debug.LogError($"No clock tower in play! {role}");
			return _board;
		}
		List<int> list = (from _r in (locationsInPlay[LocationTypes.CLOCK_TOWER] as ClockTower).scheduled_rings
			where _r.Item2.equalToAny(ClockTower.ClockTowerRingAttribution.CLOCKTOWER, ClockTower.ClockTowerRingAttribution.FEARMONGER)
			select _r.Item1).ToList();
		if (list.Count == 0)
		{
			Debug.LogError($"Clock tower has no ring times? {role}");
			return _board;
		}
		ring_time = list.getRandomElementFromList(random);
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (!base.has_bad_info && ring_time != -1)
		{
			return getInfoStringWithTime(ring_time);
		}
		Dictionary<LocationTypes, LocationData> locationsInPlay = _snap.board.getLocationsInPlay();
		if (!locationsInPlay.ContainsKey(LocationTypes.CLOCK_TOWER))
		{
			if (!base.has_bad_info)
			{
				return "There is no Clock Tower in this town.";
			}
			return getInfoStringWithTime(random.Next(1, 24));
		}
		ClockTower clockTower = locationsInPlay[LocationTypes.CLOCK_TOWER] as ClockTower;
		List<int> list = clockTower.recorded_rings.copy().addRange(clockTower.scheduled_rings.Select((STupple<int, ClockTower.ClockTowerRingAttribution> _e) => _e.Item1));
		if (base.has_bad_info)
		{
			List<int> list2 = new List<int>();
			for (int i = 2; i < 24; i++)
			{
				if (!list.Contains(i) && !list.Contains(i - 1) && !list.Contains(i + 1))
				{
					list2.Add(i);
				}
			}
			return getInfoStringWithTime(list2.getRandomElementFromList(random));
		}
		return getInfoStringWithTime(list.getRandomElementFromList(random));
	}

	public RoleData createAndForceSetInfo(int _time)
	{
		base.info_string = getInfoStringWithTime(_time).maybe();
		return this;
	}

	private string getInfoStringWithTime(int _hour)
	{
		return checkTranslationWithReplace(() => getInfoEnglish(_hour.ToString(), (_hour + 1).ToString()), ((object)_hour).ToString, ((object)(_hour + 1)).ToString);
	}

	private string getInfoEnglish(string _data_1, string _data_2)
	{
		return "The Clock Tower will ring from " + _data_1 + "h to " + _data_2 + "h";
	}

	public override string getUniqueSaveData()
	{
		return ring_time.ToString();
	}
}
