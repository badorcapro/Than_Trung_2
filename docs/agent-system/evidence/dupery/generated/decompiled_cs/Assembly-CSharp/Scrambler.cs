using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Scrambler : RoleData, IChangeAbilityTargets
{
	public override Roles role => Roles.SCRAMBLER;

	public override string english_name => "Scrambler";

	public override string english_description => "While I am not " + Keywords.DEAD.toString() + " or " + TextHelper.arrested + ", " + "abilities".asKeyword(Keywords.ABILITY) + " that ask you to select " + TextHelper.roles + " will now select " + TextHelper.roles + " at random instead.\n" + TextHelper.iLieAndPretendSuspected;

	public override bool hasInfo => false;

	public Scrambler(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Scrambler(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		List<AdvancedGenerationConstraint> list = new List<AdvancedGenerationConstraint>();
		list.Add(new AvoidInPlayRoleGC(DisguiseConstraintType.ALWAYS_IGNORE, Roles.ACCOUNTANT));
		list.Add(new InPlayRequireRoleGC(RoleGenerationMarkers.HAS_ABILITY));
		return new RoleGenerationConstraints(list);
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
		if (!base.tainted && (base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED) || (!base.dead && !base.arrested)))
		{
			return _board.getRolesInPlay().Keys.ToList().getRandomElementsFromList(random, _targets.Count);
		}
		return _targets;
	}

	public List<AbilityData> changeAbilityData(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<AbilityData> _data, int _abil_user_address)
	{
		if (base.tainted || (!base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED) && (base.dead || base.arrested)))
		{
			return _data;
		}
		if (!_data.Any((AbilityData _d) => _d is AddressAbilityData))
		{
			return _data;
		}
		List<int> list = _board.getRolesInPlay().Keys.ToList();
		foreach (AbilityData _datum in _data)
		{
			if (_datum is AddressAbilityData addressAbilityData)
			{
				addressAbilityData.address = list.getRandomElementFromList(random);
				list.Remove(addressAbilityData.address);
			}
		}
		return _data;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
