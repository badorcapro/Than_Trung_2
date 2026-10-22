using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace BackAlleyItems;

public class WadOfCash : BackAlleysItem, IHaveAbility
{
	private const int starting_usages = 3;

	public override BackAlleysItemType type => BackAlleysItemType.WAD_OF_CASH;

	public override BackAlleysItemColour colour => BackAlleysItemColour.BLACKMARKET;

	public override BackAlleysItemCost cost => BackAlleysItemCost.PRICEY;

	protected override string english_name => "Wad of Cash";

	protected override string english_description => $"Randomise your {Keywords.HEALTH.toString()}. Has {3} use.";

	public override bool is_active => true;

	public bool abilityExhausted => base.uses_remaining <= 0;

	public int numberTargets => 0;

	public WadOfCash(System.Random _rng, int _usages = -1)
		: base(_rng, (_usages == -1) ? 3 : _usages)
	{
	}

	public string getAbilityPrompt()
	{
		return "";
	}

	public override void useItemAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<AbilityData> _data, BackAlleysCase _case)
	{
		_case.setHealthExternally(random.Next(1, _case.max_health + 1));
		spendUse();
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}
}
