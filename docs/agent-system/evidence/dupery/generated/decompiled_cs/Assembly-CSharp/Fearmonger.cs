using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Fearmonger : ClockRoleData
{
	public static int ring_gaps = 6;

	public static int total_ring_times = 5;

	private int rings;

	public override Roles role => Roles.FEARMONGER;

	public override string english_name => "Fearmonger";

	public override string english_description => $"The {LocationTypes.CLOCK_TOWER.toString()} will ring every {ring_gaps} hours instead of its standard single random ring.\nAfter the fifth ring, if I am not {TextHelper.deadOrArrested}, I will destroy your {Keywords.REPUTATION.toString()}.\n" + "I add a " + LocationTypes.CLOCK_TOWER.toString() + " on the " + Keywords.BOARD.toString() + " when I am " + Keywords.SUSPECTED.toString() + ".\n" + TextHelper.iLieAndPretendNotInPlay;

	public override string credits => "NotSoDogNinja";

	public override bool hasInfo => false;

	private string loc_last_ring_key => $"{role} [lr]";

	public Fearmonger(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
		rings = 0;
	}

	public Fearmonger(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			rings = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nData: {_save.unique_data}\nError: {arg}");
			rings = 0;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new SuspectLocationGC(LocationTypes.CLOCK_TOWER));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onLocationTriggeredAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects, LocationData _location)
	{
		if (_location.location_type != LocationTypes.CLOCK_TOWER)
		{
			return _board;
		}
		rings++;
		if (rings != 5 || base.tainted || ((base.dead || base.arrested) && !base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED)))
		{
			return _board;
		}
		base.clock_case.setReputationExternally(0, checkTranslation(loc_last_ring_key, englishLastRing));
		return base.onLocationTriggeredAction(_board, _payload, _suspects, _location);
	}

	private string englishLastRing()
	{
		return "CLOCKTOWER TOLLS FOR THE LAST TIME";
	}

	public override string getUniqueSaveData()
	{
		return rings.ToString();
	}
}
