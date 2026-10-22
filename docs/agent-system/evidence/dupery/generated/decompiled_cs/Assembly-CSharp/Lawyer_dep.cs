using System;
using GRGLib.Extensions.String;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Lawyer_dep : RoleData
{
	public override Roles role => Roles.S_LAWYER;

	public override string english_name => "Lawyer";

	public override string english_description => "While I am " + TextHelper.investigated + ", " + Keywords.UNARRESTED.toString() + ", and " + Keywords.ALIVE.toString() + ", " + "arresting".asKeyword(Keywords.ARREST) + " a " + TextHelper.goodRole + " now only reduces your " + Keywords.REPUTATION.toString() + " by " + "1".bold() + ".";

	public override bool hasInfo => false;

	public Lawyer_dep(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public Lawyer_dep(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getUniqueSaveData()
	{
		return "";
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}
}
