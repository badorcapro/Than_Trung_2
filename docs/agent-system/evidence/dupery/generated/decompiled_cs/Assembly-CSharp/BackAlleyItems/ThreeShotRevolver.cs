using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace BackAlleyItems;

public class ThreeShotRevolver : BackAlleysItem, IHaveRoleAbility, IHaveAbility
{
	private const int starting_usages = 3;

	public override BackAlleysItemType type => BackAlleysItemType.THREE_SHOT_REVOLVER;

	public override BackAlleysItemColour colour => BackAlleysItemColour.BLACKMARKET;

	public override BackAlleysItemCost cost => BackAlleysItemCost.EXPENSIVE;

	protected override string english_name => "Three Shot Revolver";

	protected override string english_description => $"Pick a role. If they are {Alignments.EVIL.toString()}, they {TextHelper.die}. Has {3} uses.";

	public override bool is_active => true;

	public bool abilityExhausted => base.uses_remaining <= 0;

	public int numberTargets => 1;

	public bool allowSelfTarget => false;

	public ThreeShotRevolver(System.Random _rng, int _usages = -1)
		: base(_rng, (_usages == -1) ? 3 : _usages)
	{
	}

	public string getAbilityPrompt()
	{
		return "Pick a role.";
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		return !_roll_candidate.getIsDead();
	}

	public override void useItemAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<AbilityData> _data, BackAlleysCase _case)
	{
		int address = (_data[0] as AddressAbilityData).address;
		if (_board.getRolesInPlay()[address].getVisualAlignment() == Alignments.EVIL)
		{
			_case.killAddress(address, new Maybe<RoleData>());
		}
		spendUse();
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}
}
