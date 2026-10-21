using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using UnityEngine;

namespace BackAlleyItems;

public class EvilMonocle : BackAlleysItem, IHaveAbility
{
	private static int starting_usages = 1;

	public override BackAlleysItemType type => BackAlleysItemType.EVIL_MONOCLE;

	public override BackAlleysItemColour colour => BackAlleysItemColour.ILLEGAL;

	public override BackAlleysItemCost cost => BackAlleysItemCost.NORMAL;

	protected override string english_name => "Evil Monocle";

	protected override string english_description => string.Format("{0} a random {1} {2}. Has {3} use.", "Reveal".asKeyword(Keywords.REVEAL), TextHelper.aliveAndNotArrested, TextHelper.pretendingRole, starting_usages);

	public override bool is_active => true;

	public bool abilityExhausted => base.uses_remaining <= 0;

	public int numberTargets => 0;

	public EvilMonocle(System.Random _rng, int _usages = -1)
		: base(_rng, (_usages == -1) ? starting_usages : _usages)
	{
	}

	public string getAbilityPrompt()
	{
		return "";
	}

	public override void useItemAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<AbilityData> _data, BackAlleysCase _case)
	{
		List<RoleData> list = _board.getRolesInPlay().Values.Where((RoleData _r) => _r.getIsDisguised() && !_r.getIsDead() && !_r.getIsArrested()).ToList();
		if (list.Count != 0)
		{
			list.getRandomElementFromList(random).setDisguise(new Maybe<RoleData>());
			spendUse();
		}
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}
}
