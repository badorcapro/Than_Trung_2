using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Shark : DocksRoleData
{
	private bool triggered;

	private int killed = -1;

	public override Roles role => Roles.SHARK;

	public override string english_name => "Shark";

	public override string english_description => "The first time the " + Keywords.BOAT.toString() + " moves onto me or " + Keywords.CARDINALLY_ADJACENT.toString() + " to me, I " + Keywords.KILL.toString() + " the " + Roles.FISHERMAN.toString() + ". " + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I am never " + Keywords.CARDINALLY_ADJACENT.toString() + " to the " + LocationTypes.DOCKS.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => killed > 0;

	public Shark(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Shark(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			killed = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}! {_save.unique_data} | Error: {arg}");
			killed = -1;
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new List<AdvancedGenerationConstraint>
		{
			new PositionLocationGC(LocationTypes.DOCKS, GCPosition.NOT_ADJACENT, DisguiseConstraintType.IGNORE_WHEN_LYING),
			new InPlayRequireRoleGC(Roles.FISHERMAN)
		});
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		return "";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.tainted || base.dead || base.arrested || triggered)
		{
			return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
		}
		if (_new_pos.cardinalDistance(base.board_position) <= 1)
		{
			triggered = true;
			RoleData roleData = _board.getRolesInPlay().Values.First((RoleData _r) => _r.role == Roles.FISHERMAN);
			if (roleData == null || roleData.getIsDead())
			{
				return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
			}
			base.case_ref.killAddress(roleData.getAddress(), ((RoleData)this).maybe());
		}
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getUniqueSaveData()
	{
		return $"{killed}";
	}

	public override string getTruthString()
	{
		return ((killed <= 0) ? "" : (TextHelper.killedOneLocalised(killed) + "\n")) + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == killed;
		}
		return false;
	}
}
