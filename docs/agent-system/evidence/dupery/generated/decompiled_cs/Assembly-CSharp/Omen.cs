using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Omen : DocksRoleData
{
	private List<int> roles_obscured = new List<int>();

	public override Roles role => Roles.OMEN;

	public override string english_name => "Omen";

	public override string english_description => "I might " + Keywords.OBSCURE.toString() + " any " + Keywords.ROLE.toString() + " you move the " + Keywords.BOAT.toString() + " onto. " + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I have a 50% chance to " + Keywords.OBSCURE.toString() + " any " + Keywords.ROLE.toString() + " you move the " + Keywords.BOAT.toString() + " onto."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", " + TextHelper.deadOrArrested + ", I do not " + Keywords.OBSCURE.toString() + " any " + Keywords.ROLE.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => roles_obscured.Count > 0;

	public Omen(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Omen(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		roles_obscured = RoleHelper.tryLoadListFromUniqueData(role, _save);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.OBSCURES);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		if (!_board[_new_pos].is_some || !_board[_new_pos].value.is_a)
		{
			return _board;
		}
		RoleData value = _board[_new_pos].value.maybe_a.value;
		int item = value.getAddress();
		if (roles_obscured.Contains(item))
		{
			return _board;
		}
		if (random.Next(0, 2) == 1)
		{
			value.setObscured(_new: true);
			roles_obscured.Add(item);
			return _board;
		}
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getTruthString()
	{
		return ((roles_obscured.Count == 0) ? "" : (TextHelper.obscuredManyLocalised(roles_obscured) + "\n")) + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return roles_obscured.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return roles_obscured.toStringCommaSeperated();
	}
}
