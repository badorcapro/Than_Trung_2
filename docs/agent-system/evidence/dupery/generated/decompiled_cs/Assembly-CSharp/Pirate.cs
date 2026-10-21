using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Pirate : DocksRoleData
{
	private List<int> killed_targets = new List<int>();

	public override Roles role => Roles.PIRATE;

	public override string english_name => "Pirate";

	public override string english_description => "When the " + Keywords.BOAT.toString() + " moves onto any of my " + TextHelper.adjacentNeighbours + ", I might " + Keywords.KILL.toString() + " them. " + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I have a 50% chance of " + TextHelper.killing + " my " + TextHelper.adjacentNeighbours + " when the " + Keywords.BOAT.toString() + " moves onto them."));
			list.Add((DescriptionType.SPECIAL, "I always have at least 1 " + TextHelper.adjacentNeighbour + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => killed_targets.Count > 0;

	public Pirate(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Pirate(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			killed_targets = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			killed_targets = new List<int>();
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new PositionRoleGC(GCPosition.ADJACENT, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		return "";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
		}
		if (_new_pos.cardinalDistance(base.board_position) == 1 && (base.docks_case.hasMarkerQuirk(CaseQuirks.VIOLENT_PIRACY) || random.Next(0, 2) == 1))
		{
			Maybe<RoleData> roleAtBoardPosition = _new_pos.getRoleAtBoardPosition(_board, (RoleData _r) => !_r.getIsDead());
			if (roleAtBoardPosition.is_some)
			{
				base.case_ref.killAddress(roleAtBoardPosition.value.getAddress(), ((RoleData)this).maybe());
				killed_targets.Add(roleAtBoardPosition.value.getAddress());
			}
		}
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getUniqueSaveData()
	{
		return killed_targets.toStringCommaSeperated();
	}

	public override string getTruthString()
	{
		return ((killed_targets.Count == 0) ? "" : (TextHelper.killedManyLocalised(killed_targets) + "\n")) + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return killed_targets.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}
}
