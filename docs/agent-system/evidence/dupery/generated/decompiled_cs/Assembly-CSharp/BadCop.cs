using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class BadCop : RoleData
{
	public override Roles role => Roles.BAD_COP;

	public override string english_name => "Bad Cop";

	public override string english_description => "I " + Keywords.PRETEND.toString() + " to be the " + Roles.GOOD_COP.toString() + ". When I am " + Keywords.IN_PLAY.toString() + ", the " + Roles.GOOD_COP.toString() + " is " + Keywords.IN_PLAY.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I do not " + Keywords.LIE.toString() + "! Using the " + Keywords.ABILITY.toString() + " of the " + Roles.GOOD_COP.toString() + " I am " + TextHelper.pretending + " to be will make " + TextHelper.roles + " " + Alignments.EVIL.toString() + "!"));
			return list;
		}
	}

	public override bool hasInfo => false;

	public BadCop(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public BadCop(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return new DisguiseCharacteristics(Roles.GOOD_COP);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new InPlayRequireRoleGC(Roles.GOOD_COP, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getUniqueSaveData()
	{
		return "";
	}

	protected override bool isLiar()
	{
		return false;
	}
}
