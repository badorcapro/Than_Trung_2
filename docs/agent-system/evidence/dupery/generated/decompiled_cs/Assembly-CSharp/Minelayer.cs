using System;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Minelayer : DocksRoleData
{
	public override Roles role => Roles.MINELAYER;

	public override string english_name => "Minelayer";

	public override string english_description => "I add a " + LocationTypes.NAVAL_MINE.toString() + " on the " + Keywords.BOARD.toString() + ". If the " + Keywords.BOAT.toString() + " is ever on the " + LocationTypes.NAVAL_MINE.toString() + ", " + $"it explodes {TextHelper.killing} all {TextHelper.adjacentNeighbours} and costing you {4} {Keywords.FUEL.toString()}. {TextHelper.iLieAndPretendSuspected}.";

	public override bool hasInfo => false;

	public Minelayer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Minelayer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new InPlayLocationGC(LocationTypes.NAVAL_MINE, DisguiseConstraintType.IGNORE_WHEN_LYING));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
