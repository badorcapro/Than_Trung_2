using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Casanova : RoleData
{
	public override Roles role => Roles.CASANOVA;

	public override string english_name => "Casanova";

	public override string english_description => "I am " + Keywords.SURROUNDING.toString() + " the " + Roles.ROMANTIC.toString() + "'s lover unless the " + Roles.ROMANTIC.toString() + " is " + TextHelper.lyingOrTainted + ".\nI charm the " + Roles.ROMANTIC.toString() + "'s lover and run away with them.\n" + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, "When I am " + TextHelper.tainted + " I do not charm the " + Roles.ROMANTIC.toString() + "'s lover."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Casanova(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Casanova(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new CasanovaGC());
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.EVIL;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.UNDERLING;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
