using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Misguided : RoleData
{
	public override Roles role => Roles.MISGUIDED;

	public override string english_name => "Misguided";

	public override string english_description => "I " + Keywords.PRETEND.toString() + " to be a " + Keywords.NOT_IN_PLAY.toString() + " " + TextHelper.revealed + " " + RoleClassifications.UNDERLING.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I do not " + Keywords.PRETEND.toString() + " to be " + TextHelper.tainted + " which means I do the actions of the " + TextHelper.underlingRole + " I am " + TextHelper.pretending + " to be."));
			return list;
		}
	}

	public override string credits => "Rsvdark";

	public override bool hasInfo => false;

	public override bool can_be_disguise => false;

	public Misguided(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Misguided(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return new DisguiseCharacteristics(DisguiseTarget.NOT_IN_PLAY, new List<RoleClassifications> { RoleClassifications.UNDERLING }, new List<Roles>(), _check_disguise_constraints: false);
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
