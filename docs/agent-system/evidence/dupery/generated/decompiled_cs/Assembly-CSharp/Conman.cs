using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Conman : RoleData
{
	public override Roles role => Roles.CONMAN;

	public override Roles reveal_as
	{
		get
		{
			if (!disguise.is_some)
			{
				return role;
			}
			return disguise.value.role;
		}
	}

	public override string english_name => "Conman";

	public override string english_description => "I " + Keywords.PRETEND.toString() + " to be an " + TextHelper.inPlayRole + ".\nWhen I am " + TextHelper.arrested + ", I am not " + TextHelper.revealed + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "Unlike most other " + TextHelper.underlingRoles + ", I do not " + Keywords.LIE.toString() + "!"));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Conman(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Conman(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.IN_PLAY);
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
}
