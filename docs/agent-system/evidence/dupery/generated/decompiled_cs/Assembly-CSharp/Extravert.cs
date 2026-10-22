using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Extravert : RoleData
{
	public override Roles role => Roles.EXTRAVERT;

	public override string english_name => "Extravert";

	public override string english_description => "I start " + TextHelper.investigated + ". One of my " + TextHelper.surroundingNeighbours + " starts " + TextHelper.investigated + ". " + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I am always " + Keywords.SURROUNDING.toString() + " at least 1 other " + Keywords.ROLE.toString() + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTaintedMyBehaviourRemains));
			return list;
		}
	}

	public override string credits => "Rsvdark";

	public override bool hasInfo => false;

	public Extravert(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public Extravert(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new PositionRoleGC(GCPosition.SURROUNDING, DisguiseConstraintType.NEVER_IGNORE));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override bool isLiar()
	{
		return true;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		setInvestigatedOuter();
		List<RoleData> surroundingRolesFromGridPos = _board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size);
		if (surroundingRolesFromGridPos.Count == 0)
		{
			Debug.LogError($"{role} started with no neighbours? This should not be possible!");
			return _board;
		}
		surroundingRolesFromGridPos.getRandomElementFromList(random).setInvestigatedOuter();
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
