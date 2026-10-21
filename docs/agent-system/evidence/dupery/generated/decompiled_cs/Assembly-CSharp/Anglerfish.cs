using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Anglerfish : DocksRoleData
{
	public override Roles role => Roles.ANGLERFISH;

	public override string english_name => "Anglerfish";

	public override string english_description => "I " + Keywords.HIDE.toString() + ". " + TextHelper.iLieAndPretendSuspected + ".";

	public override bool hasInfo => false;

	public Anglerfish(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Anglerfish(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HIDES);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted)
		{
			return _board;
		}
		base.hidden = true;
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
