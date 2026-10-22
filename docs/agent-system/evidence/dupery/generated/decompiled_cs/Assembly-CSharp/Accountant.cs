using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Accountant : RoleData, IChangeAbilityTargets
{
	public override Roles role => Roles.ACCOUNTANT;

	public override string english_name => "Accountant";

	public override string english_description => "While I am not " + Keywords.DEAD.toString() + " or " + TextHelper.arrested + ", " + "abilities".asKeyword(Keywords.ABILITY) + " that ask you to select " + TextHelper.roles + " will now select " + TextHelper.roles + " one " + Keywords.ADDRESS.toString() + " along from your selections.\n" + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "With an " + Roles.ACCOUNTANT.toString() + " " + Keywords.IN_PLAY.toString() + ", if you tried to use an " + Keywords.ABILITY.toString() + " on the #3 " + Keywords.ROLE.toString() + ", the ability would instead trigger on the #4 " + Keywords.ROLE.toString() + ". If you picked the highest " + Keywords.ADDRESS.toString() + ", the lowest " + Keywords.ADDRESS.toString() + " will be selected instead."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Accountant(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Accountant(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		List<AdvancedGenerationConstraint> list = new List<AdvancedGenerationConstraint>();
		list.Add(new AvoidInPlayRoleGC(DisguiseConstraintType.ALWAYS_IGNORE, Roles.SCRAMBLER));
		list.Add(new InPlayRequireRoleGC(RoleGenerationMarkers.HAS_ABILITY, 1, DisguiseConstraintType.ALWAYS_IGNORE));
		return new RoleGenerationConstraints(list);
	}

	protected override bool getEnglishNamePrefixOption()
	{
		return false;
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public List<int> changeAbilityTargets(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<int> _targets, int _abil_user_address)
	{
		if (base.tainted || base.arrested || base.dead)
		{
			return _targets;
		}
		int roles_in_play = _board.getRolesInPlay().Count;
		return _targets.Select((int _i) => _i % roles_in_play + 1).ToList();
	}

	public List<AbilityData> changeAbilityData(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<AbilityData> _data, int _abil_user_address)
	{
		if (base.arrested || base.dead || base.tainted)
		{
			return _data;
		}
		int count = _board.getRolesInPlay().Count;
		foreach (AbilityData _datum in _data)
		{
			if (_datum is AddressAbilityData addressAbilityData)
			{
				addressAbilityData.address = addressAbilityData.address % count + 1;
			}
		}
		return _data;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
