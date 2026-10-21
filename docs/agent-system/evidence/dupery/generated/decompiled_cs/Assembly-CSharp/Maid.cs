using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Maid : ClockRoleData
{
	private List<int> targets = new List<int>();

	private bool taint_next;

	public override Roles role => Roles.MAID;

	public override string english_name => "Maid";

	public override string english_description => "When the " + LocationTypes.CLOCK_TOWER.toString() + " rings, I " + Keywords.TAINT.toString() + " the next " + TextHelper.innocent + " " + Keywords.ROLE.toString() + " you " + Keywords.INVESTIGATE.toString() + ".\nI add a " + LocationTypes.CLOCK_TOWER.toString() + " on the " + Keywords.BOARD.toString() + " when I am " + Keywords.SUSPECTED.toString() + ".\n" + TextHelper.iLieAndPretendSuspected;

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I do not " + Keywords.TAINT.toString() + " if I am " + TextHelper.deadOrArrested + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => targets.Count > 0;

	public Maid(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Maid(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split('#');
			taint_next = array[0] == "t";
			targets = array[1].fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\n{_save.unique_data}\nError: {arg}");
			taint_next = false;
			targets = new List<int>();
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.TAINTS, new SuspectLocationGC(LocationTypes.CLOCK_TOWER));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onLocationTriggeredAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects, LocationData _location)
	{
		if (_location.location_type == LocationTypes.CLOCK_TOWER && !base.arrested && !base.dead && !base.tainted)
		{
			taint_next = true;
		}
		return base.onLocationTriggeredAction(_board, _payload, _suspects, _location);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (!taint_next || base.dead || base.arrested || base.tainted)
		{
			return _board;
		}
		RoleData roleData = _board.getRolesInPlay()[_investigated_address];
		if (roleData.getVisualClassification() == RoleClassifications.INNOCENT)
		{
			roleData.setTainted(_new: true);
			taint_next = false;
			targets.Add(roleData.getAddress());
		}
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	public override string getUniqueSaveData()
	{
		return (taint_next ? "t" : "f") + "#" + targets.toStringCommaSeperated();
	}

	public override string getTruthString()
	{
		return ((targets.Count > 0) ? (TextHelper.taintedManyLocalised(targets) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return targets.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}
}
