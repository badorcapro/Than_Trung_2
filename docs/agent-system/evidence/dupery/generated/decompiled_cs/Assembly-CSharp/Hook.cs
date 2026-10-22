using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Hook : DocksRoleData
{
	public override Roles role => Roles.HOOK;

	public override string english_name => "Hook";

	public override string english_description => "All " + TextHelper.roles + " consider me as a " + Alignments.GOOD.toString() + " " + RoleClassifications.INNOCENT.toString() + " unless I am " + TextHelper.adjacentOrOnTheBoat + ". " + TextHelper.ipretendInPlay + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I trick " + TextHelper.roles + " that specifically check my " + Keywords.ALIGNMENT.toString() + " or " + Keywords.CLASSIFICATION.toString() + "."));
			list.Add((DescriptionType.SPECIAL, "Unlike most other " + TextHelper.traitorRoles + ", I do not " + Keywords.LIE.toString() + "!"));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Hook(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Hook(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.IN_PLAY);
	}

	public override Alignments getVisualAlignment()
	{
		if (base.docks_case != null && !isAdjacentOrOnBoat())
		{
			return Alignments.GOOD;
		}
		return Alignments.EVIL;
	}

	public override RoleClassifications getVisualClassification()
	{
		if (base.docks_case != null && !isAdjacentOrOnBoat())
		{
			return RoleClassifications.INNOCENT;
		}
		return RoleClassifications.TRAITOR;
	}

	private bool isAdjacentOrOnBoat()
	{
		if (base.docks_case.boat != null)
		{
			return base.docks_case.boat.position.isAdjacentOrOn(base.board_position);
		}
		return true;
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		return "";
	}

	protected override bool isLiar()
	{
		return false;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
