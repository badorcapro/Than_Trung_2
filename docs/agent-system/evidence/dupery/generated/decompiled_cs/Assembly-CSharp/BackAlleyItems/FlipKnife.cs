using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using UnityEngine;

namespace BackAlleyItems;

public class FlipKnife : BackAlleysItem, IHaveAbility
{
	public override BackAlleysItemType type => BackAlleysItemType.FLIP_KNIFE;

	public override BackAlleysItemColour colour => BackAlleysItemColour.ILLEGAL;

	public override BackAlleysItemCost cost => BackAlleysItemCost.CHEAP;

	protected override string english_name => "Flip Knife";

	protected override string english_description => string.Format("{0} a random {1}, {2} {3}. Has {4} use per Case.", "Kill".asKeyword(Keywords.KILL), TextHelper.investigated, TextHelper.aliveAndNotArrested, Keywords.ROLE.toString(), uses_per_case);

	public override bool is_active => true;

	public override int uses_per_case => 1;

	public bool abilityExhausted => base.uses_remaining <= 0;

	public int numberTargets => 0;

	public FlipKnife(System.Random _rng, int _usages = -1)
		: base(_rng, _usages)
	{
	}

	public string getAbilityPrompt()
	{
		return "";
	}

	public override void useItemAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<AbilityData> _data, BackAlleysCase _case)
	{
		List<RoleData> list = _board.getRolesInPlay().Values.Where((RoleData _r) => _r.getIsInvestigated() && !_r.getIsDead() && !_r.getIsArrested()).ToList();
		if (list.Count != 0)
		{
			RoleData randomElementFromList = list.getRandomElementFromList(random);
			_case.killAddress(randomElementFromList.getAddress(), new Maybe<RoleData>());
			spendUse();
		}
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}
}
