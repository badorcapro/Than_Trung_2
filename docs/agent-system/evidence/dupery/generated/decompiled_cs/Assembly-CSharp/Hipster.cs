using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Hipster : RoleData
{
	public override Roles role => Roles.HIPSTER;

	public override string english_name => "Hipster";

	public override string english_description => "If I am " + Keywords.SURROUNDING.toString() + " more " + TextHelper.goodRoles + " than " + TextHelper.evilRoles + " at the start of the case, I become " + Alignments.EVIL.toString() + ".\n" + TextHelper.otherRolesCannotPretendToBeMe;

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not become " + Alignments.EVIL.toString() + " even if I am " + Keywords.SURROUNDING.toString() + " more " + TextHelper.goodRoles + " than " + TextHelper.evilRoles + "."));
			return list;
		}
	}

	public override bool can_be_disguise => false;

	public override bool hasInfo => false;

	public Hipster(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public Hipster(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new PositionRoleGC(GCPosition.SURROUNDING, DisguiseConstraintType.NEVER_IGNORE));
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		List<RoleData> surroundingRolesFromGridPos = _board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size);
		if (surroundingRolesFromGridPos.Count == 0)
		{
			Debug.LogError($"{role} started with no neighbours? This should not be possible!");
			return _board;
		}
		if (surroundingRolesFromGridPos.Count((RoleData _r) => _r.getVisualAlignment() == Alignments.GOOD) * 2 > surroundingRolesFromGridPos.Count)
		{
			setAlignment(Alignments.EVIL);
		}
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
