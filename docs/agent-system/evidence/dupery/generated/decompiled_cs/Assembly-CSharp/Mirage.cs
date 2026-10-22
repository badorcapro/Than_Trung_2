using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Mirage : DocksRoleData
{
	private Maybe<RoleData> pretending_as = new Maybe<RoleData>();

	public override Roles role => Roles.MIRAGE;

	public override string english_name => "Mirage";

	public override string english_description => TextHelper.iLieAndPretendSuspected + ". I " + Keywords.REVEAL.toString() + " myself when the " + Keywords.BOAT.toString() + " is moved onto me.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "If the " + Keywords.BOAT.toString() + " is moved off of me, I start " + TextHelper.pretending + " again."));
			return list;
		}
	}

	public override string credits => "Exiliado89";

	public override bool hasInfo => false;

	public Mirage(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Mirage(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			int num = int.Parse(_save.unique_data);
			if (num == -1)
			{
				pretending_as = new Maybe<RoleData>();
			}
			else
			{
				pretending_as = ((Roles)num).createRole(base.address, base.board_position, _random, ((RoleData)this).maybe()).maybe();
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			pretending_as = new Maybe<RoleData>();
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override bool isLiar()
	{
		return true;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.dead || base.arrested)
		{
			return _board;
		}
		if (base.board_position == _old_pos && base.board_position != _new_pos)
		{
			setDisguise(pretending_as);
			return _board;
		}
		if (base.board_position == _new_pos)
		{
			if (disguise.is_some)
			{
				pretending_as = disguise.value.maybe();
			}
			setDisguise(new Maybe<RoleData>());
			return _board;
		}
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getUniqueSaveData()
	{
		return $"{(int)(pretending_as.is_some ? pretending_as.value.role : ((Roles)(-1)))}";
	}
}
