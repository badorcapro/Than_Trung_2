using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class IneptCadet : DocksRoleData
{
	public override Roles role => Roles.INEPT_CADET;

	public override string english_name => "Inept Cadet";

	public override string english_description => TextHelper.ipretendSuspectedInnocent + ". When the " + Keywords.BOAT.toString() + " is not on or " + Keywords.CARDINALLY_ADJACENT.toString() + " to me, I " + Keywords.LIE.toString() + ". Otherwise I do not " + Keywords.LIE.toString() + ". I am always " + Keywords.CARDINALLY_ADJACENT.toString() + " to the " + LocationTypes.DOCKS.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)>
	{
		(DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves),
		(DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", even if I am not " + TextHelper.lying + ", the information I give will be incorrect.")
	};

	public override bool hasInfo => false;

	public IneptCadet(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public IneptCadet(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getInnocentDisguise(DisguiseTarget.SUSPECTED);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new PositionLocationGC(LocationTypes.DOCKS, GCPosition.ADJACENT, DisguiseConstraintType.NEVER_IGNORE));
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		bool num = base.has_bad_info;
		base.lying = !_new_pos.isAdjacentOrOn(base.board_position);
		if (num != base.has_bad_info && !base.dead)
		{
			resetInfo();
		}
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
