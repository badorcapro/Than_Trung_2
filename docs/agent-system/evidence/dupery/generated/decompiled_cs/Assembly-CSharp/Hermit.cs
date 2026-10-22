using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Hermit : RoleData
{
	public override Roles role => Roles.HERMIT;

	public override string english_name => "Hermit";

	public override string english_description => "I cannot be " + TextHelper.investigated + " if there is an " + TextHelper.investigated + ", " + TextHelper.aliveAndNotArrested + " " + TextHelper.evilRole + " " + Keywords.SURROUNDING.toString() + " me.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I can only be " + TextHelper.investigated + " if there is an " + TextHelper.investigated + ", " + TextHelper.aliveAndNotArrested + " " + TextHelper.evilRole + " " + Keywords.SURROUNDING.toString() + " me."));
			return list;
		}
	}

	public override string credits => "I am imprest & gv";

	public override bool hasInfo => false;

	public Hermit(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public Hermit(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.INVESTIGATION_BLOCKER, new PositionRoleGC(GCPosition.SURROUNDING, DisguiseConstraintType.NEVER_IGNORE));
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getUniqueSaveData()
	{
		return "";
	}

	public override bool canBeInvestigated(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		bool flag = _board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size).Any((RoleData _r) => _r.getVisualAlignment() == Alignments.EVIL && _r.getIsInvestigated() && !_r.getIsDead() && !_r.getIsArrested());
		if (base.canBeInvestigated(_board))
		{
			if (!base.has_bad_info)
			{
				return !flag;
			}
			return flag;
		}
		return false;
	}
}
