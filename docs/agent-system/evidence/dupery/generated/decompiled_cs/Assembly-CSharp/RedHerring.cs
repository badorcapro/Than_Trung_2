using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class RedHerring : DocksRoleData
{
	public override Roles role => Roles.RED_HERRING;

	public override string english_name => "Red Herring";

	public override string english_description => "I " + Keywords.HIDE.toString() + ". I " + Keywords.PRETEND.toString() + " to be a " + Roles.HERRING.toString() + ".\nWhen I am " + Keywords.IN_PLAY.toString() + ", the " + Roles.HERRING.toString() + " is also " + Keywords.IN_PLAY.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTaintedMyBehaviourRemains) };

	public override bool hasInfo => false;

	public RedHerring(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public RedHerring(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HIDES, new InPlayRequireRoleGC(Roles.HERRING));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return new DisguiseCharacteristics(Roles.HERRING);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		base.hidden = true;
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
