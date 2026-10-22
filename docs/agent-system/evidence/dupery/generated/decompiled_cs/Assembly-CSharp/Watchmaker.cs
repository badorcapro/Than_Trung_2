using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Watchmaker : ClockRoleData
{
	public override Roles role => Roles.WATCHMAKER;

	public override string english_name => "Watchmaker";

	public override string english_description => "Whenever you use a " + Keywords.ROLE.toString() + "'s " + Keywords.ABILITY.toString() + ", an extra hour passes. " + TextHelper.iLieAndPretendSuspected + " with an " + Keywords.ABILITY.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.SPECIAL, "I do not make extra time pass if I am " + TextHelper.deadOrArrested + ".") };

	public override string credits => "Rsvdark";

	public override bool hasInfo => false;

	public Watchmaker(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Watchmaker(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new InPlayRequireRoleGC(RoleGenerationMarkers.HAS_ABILITY, 1, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return new DisguiseCharacteristics(DisguiseTarget.CUSTOM_SUSPECTED, new List<RoleClassifications>
		{
			RoleClassifications.INNOCENT,
			RoleClassifications.MEDDLER
		}, (RoleData _r) => _r.getHasAnyAbility(), new List<Roles>());
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		base.clock_case.waitTime();
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
