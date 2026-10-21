using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Copycat : RoleData
{
	public override Roles role => Roles.COPYCAT;

	public override string english_name => "Copycat";

	public override string english_description => "I " + Keywords.PRETEND.toString() + " to be a " + Alignments.GOOD.toString() + " " + TextHelper.inPlayRole + ".";

	public override bool hasInfo => false;

	public Copycat(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Copycat(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return new DisguiseCharacteristics(DisguiseTarget.IN_PLAY, new List<RoleClassifications>
		{
			RoleClassifications.INNOCENT,
			RoleClassifications.MEDDLER
		}, new List<Roles> { Roles.MILKMAN });
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.MEDDLER;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
