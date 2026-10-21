using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace BackAlleyItems;

public class Lighter : BackAlleysItem, IHaveRoleAbility, IHaveAbility
{
	public override BackAlleysItemType type => BackAlleysItemType.LIGHTER;

	public override BackAlleysItemColour colour => BackAlleysItemColour.MISCHEVIOUS;

	public override BackAlleysItemCost cost => BackAlleysItemCost.NORMAL;

	protected override string english_name => "Lighter";

	protected override string english_description => $"Pick a role. {TextHelper.unobscure} them. Has {uses_per_case} use per Case.";

	public override bool is_active => true;

	public override int uses_per_case => 1;

	public bool abilityExhausted => base.uses_remaining <= 0;

	public int numberTargets => 1;

	public bool allowSelfTarget => false;

	public Lighter(System.Random _rng, int _usages = -1)
		: base(_rng, _usages)
	{
	}

	public string getAbilityPrompt()
	{
		return "Pick a role.";
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		if (_roll_candidate.getIsInvestigated())
		{
			return _roll_candidate.getIsObscured();
		}
		return false;
	}

	public override void useItemAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<AbilityData> _data, BackAlleysCase _case)
	{
		_board.getRolesInPlay()[(_data[0] as AddressAbilityData).address].setObscured(_new: false);
		spendUse();
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}
}
