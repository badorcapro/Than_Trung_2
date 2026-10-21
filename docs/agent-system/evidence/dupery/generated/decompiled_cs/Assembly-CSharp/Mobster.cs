using System;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Mobster : RoleData
{
	public override Roles role => Roles.MOBSTER;

	public override string english_name => "Mobster";

	public override string english_description => TextHelper.iLieAndPretendInPlay + ".";

	public override bool hasInfo => false;

	public Mobster(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Mobster(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.IN_PLAY);
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
