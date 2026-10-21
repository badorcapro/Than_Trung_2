using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Absconder : DocksRoleData
{
	public override Roles role => Roles.ABSCONDER;

	public override string english_name => "Absconder";

	public override string english_description => "I " + Keywords.HIDE.toString() + ". " + TextHelper.iLieAndPretendSuspected + ". Whenever I am " + TextHelper.adjacentOrOnTheBoat + " and it moves away, I " + Keywords.HIDE.toString() + " myself once more.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I " + Keywords.HIDE.toString() + " when the " + Keywords.BOAT.toString() + " moves from a position that was " + Keywords.CARDINALLY_ADJACENT.toString() + " or on me to a position that is 2 or more " + Keywords.STEPS.toString() + " away from me."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Absconder(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Absconder(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
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

	protected override bool isLiar()
	{
		return true;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.dead || base.arrested)
		{
			return _board;
		}
		base.hidden = true;
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.dead || base.arrested)
		{
			return _board;
		}
		if (_old_pos.cardinalDistance(base.board_position) <= 1 && _new_pos.cardinalDistance(base.board_position) >= 2)
		{
			base.hidden = true;
		}
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
