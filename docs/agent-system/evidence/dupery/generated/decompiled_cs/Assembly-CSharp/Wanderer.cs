using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Wanderer : RoleData
{
	public override Roles role => Roles.WANDERER;

	public override string english_name => "Wanderer";

	public override string english_description => "I am not home. I cannot be " + TextHelper.investigated + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I can be " + TextHelper.investigated + ".") };

	public override bool hasInfo => false;

	public Wanderer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public Wanderer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.INVESTIGATION_BLOCKER);
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
		return base.has_bad_info;
	}
}
