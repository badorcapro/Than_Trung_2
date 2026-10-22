using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Belfry : ClockRoleData
{
	private int time_investigated = -1;

	public override Roles role => Roles.BELFRY;

	public override string english_name => "Belfry";

	public override string english_description => "I make the " + LocationTypes.CLOCK_TOWER.toString() + " ring an extra time when I am " + TextHelper.investigated + ".\nI add a " + LocationTypes.CLOCK_TOWER.toString() + " on the " + Keywords.BOARD.toString() + " when I am " + Keywords.SUSPECTED.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I do not cause the " + LocationTypes.CLOCK_TOWER.toString() + " to ring an extra time.") };

	public override string credits => "Wind, NotSoDogNinja";

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public Belfry(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Belfry(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			time_investigated = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}! ({_save.unique_data})\nError: {arg}");
			time_investigated = -1;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new SuspectLocationGC(LocationTypes.CLOCK_TOWER));
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_b)
		{
			return _occupent.maybe_b.value.location_type == LocationTypes.CLOCK_TOWER;
		}
		return false;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (_investigated_address != base.address || base.has_bad_info || base.dead || base.arrested)
		{
			return _board;
		}
		time_investigated = (_payload as ClockCaseActionPayload).hour_passed + 2;
		Dictionary<LocationTypes, LocationData> locationsInPlay = _board.getLocationsInPlay();
		if (!locationsInPlay.ContainsKey(LocationTypes.CLOCK_TOWER))
		{
			Debug.LogError($"No clocktower in a {role} game detected?");
			return _board;
		}
		(locationsInPlay[LocationTypes.CLOCK_TOWER] as ClockTower).ringNow(time_investigated, base.case_ref);
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return checkTranslation(englishInfo);
	}

	private string englishInfo()
	{
		return "Bing Bong Bing Bong!";
	}

	public override string getUniqueSaveData()
	{
		return time_investigated.ToString();
	}
}
