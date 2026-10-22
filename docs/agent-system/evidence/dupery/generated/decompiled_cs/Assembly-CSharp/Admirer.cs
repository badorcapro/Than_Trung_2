using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Admirer : RoleData
{
	public override Roles role => Roles.U_ADMIRER;

	public override string english_name => "Admirer";

	public override string english_description => "When I am " + Keywords.IN_PLAY.toString() + ", I add a " + LocationTypes.U_CLUE.toString() + " " + Keywords.CARDINALLY_ADJACENT.toString() + " to a " + TextHelper.underlingRole + " . " + TextHelper.iLieAndPretendSuspectedInnocent + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", my behaviour does not change.") };

	public override bool hasInfo => false;

	public override bool has_hover_focus => false;

	public Admirer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Admirer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getInnocentDisguise(DisguiseTarget.SUSPECTED);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new InPlayLocationGC(LocationTypes.U_CLUE, DisguiseConstraintType.NEVER_IGNORE));
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
