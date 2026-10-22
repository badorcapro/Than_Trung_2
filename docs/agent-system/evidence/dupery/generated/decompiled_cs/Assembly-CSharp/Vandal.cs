using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Vandal : DocksRoleData
{
	public override Roles role => Roles.VANDAL;

	public override string english_name => "Vandal";

	public override string english_description => "While I am " + TextHelper.aliveAndNotArrested + ", the amount of " + Keywords.FUEL.toString() + " you have is hidden. " + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not hide your " + Keywords.FUEL.toString() + ".") };

	public override string credits => "Funky";

	public override bool hasInfo => false;

	public Vandal(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Vandal(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		base.docks_case.setFuelHidden();
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address != base.address || base.dead || base.tainted)
		{
			return _board;
		}
		base.docks_case.setFuelHidden(_true: false);
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKillAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		if (_murdered_address != base.address || base.arrested || base.tainted)
		{
			return _board;
		}
		base.docks_case.setFuelHidden(_true: false);
		return base.onKillAction(_board, _payload, _murdered_address, _killer);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
