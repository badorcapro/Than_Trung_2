using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Fugitive : RoleData
{
	public override Roles role => Roles.FUGITIVE;

	public override string english_name => "Fugitive";

	public override string english_description => "I have run away. I cannot be " + TextHelper.investigated + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + " I can be " + TextHelper.investigated + ".") };

	public override bool hasInfo => false;

	public Fugitive(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public Fugitive(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.INVESTIGATION_BLOCKER, new List<AdvancedGenerationConstraint>
		{
			new SuspectRequireRoleGC(RoleGenerationMarkers.INVESTIGATION_BLOCKER),
			new LeadRequireGC(new List<RoleClassifications>
			{
				RoleClassifications.MEDDLER,
				RoleClassifications.UNDERLING
			}, RoleGenerationMarkers.INVESTIGATION_BLOCKER)
		});
	}

	protected override bool isLiar()
	{
		return false;
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
		return base.tainted;
	}
}
