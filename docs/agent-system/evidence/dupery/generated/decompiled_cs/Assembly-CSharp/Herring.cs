using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Herring : DocksRoleData
{
	public override Roles role => Roles.HERRING;

	public override string english_name => "Herring";

	public override string english_description => "I " + Keywords.HIDE.toString() + ". When I am " + Keywords.IN_PLAY.toString() + ", the " + Roles.RED_HERRING.toString() + " is also " + Keywords.IN_PLAY.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTaintedMyBehaviourRemains) };

	public override bool hasInfo => false;

	public Herring(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Herring(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HIDES, new List<AdvancedGenerationConstraint>
		{
			new InPlayRequireRoleGC(Roles.RED_HERRING),
			new ClassificationRatioGC(RoleClassifications.MEDDLER, 1, DisguiseConstraintType.ALWAYS_IGNORE)
		});
	}

	protected override bool isLiar()
	{
		return false;
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
