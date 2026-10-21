using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class FallGuy : RoleData
{
	public override Roles role => Roles.FALL_GUY;

	public override bool can_be_disguise => false;

	public override string english_name => "Fall Guy";

	public override string english_description => "Other " + TextHelper.roles + " consider me as an " + Alignments.EVIL.toString() + " " + RoleClassifications.UNDERLING.toString() + ". " + TextHelper.otherRolesCannotPretendToBeMe;

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I trick " + TextHelper.roles + " that specifically check my " + Keywords.ALIGNMENT.toString() + " or " + Keywords.CLASSIFICATION.toString() + "."));
			list.Add((DescriptionType.SPECIAL, "Other information they might check about me such as my " + Keywords.ROLE.toString() + " name and " + Keywords.ADDRESS.toString() + " are correct."));
			list.Add((DescriptionType.LYING_OR_TAINTED, "When I am " + TextHelper.tainted + " I appear as a " + Alignments.GOOD.toString() + " " + TextHelper.meddlerRole + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override int execution_order => 29999;

	public FallGuy(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public FallGuy(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override Alignments getVisualAlignment()
	{
		if (!base.tainted)
		{
			return Alignments.EVIL;
		}
		return Alignments.GOOD;
	}

	public override RoleClassifications getVisualClassification()
	{
		if (!base.tainted)
		{
			return RoleClassifications.UNDERLING;
		}
		return RoleClassifications.MEDDLER;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
