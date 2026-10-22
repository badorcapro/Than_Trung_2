using System;
using System.Collections.Generic;
using GRGLib.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class CardShuffler : LocationData, IHaveAbility
{
	private static MinMaxInt random_cost = new MinMaxInt(1, 5);

	private const int cost_increase_multi = 2;

	public int ability_used;

	public const int max_usages = 5;

	private bool force_closed;

	public int cost { get; private set; } = -1;

	public override LocationTypes location_type => LocationTypes.CARD_SHUFFLER;

	protected override string english_name => "Card Shuffler";

	protected override string english_description => "Don't like the " + TextHelper.cards + " in your hand! Replace them now with the all new Card Shuffler!\n<i>A small processing fee may be charged</i>.";

	public bool is_closed
	{
		get
		{
			if (!abilityExhausted)
			{
				return force_closed;
			}
			return true;
		}
	}

	public bool abilityExhausted => ability_used >= 5;

	public int numberTargets => 0;

	public CardShuffler(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
		cost = random_cost.get(_random);
	}

	public CardShuffler(LocationDataSave _save, System.Random _random)
		: base(_save, _random)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			cost = int.Parse(array[0]);
			ability_used = int.Parse(array[1]);
			force_closed = array[2] == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {location_type}! Error: {arg}");
			cost = 1;
			ability_used = 0;
			force_closed = false;
		}
	}

	public string getAbilityPrompt()
	{
		return "";
	}

	public override bool isOfRegion(Regions _region)
	{
		if (_region == Regions.CASINO)
		{
			return true;
		}
		return false;
	}

	public override void useAbility(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<AbilityData> _data)
	{
		if (!is_closed && !abilityExhausted)
		{
			if (!(_case is CasinoCase casinoCase))
			{
				Debug.LogError("Trying to use Card Shuffler in a none-casino case!");
				return;
			}
			bool flag = random.Next(0, 2) == 1;
			casinoCase.drawNewCards(flag, !flag);
			casinoCase.spendChips(cost);
			cost *= 2;
			ability_used++;
		}
	}

	public void forceCloseShuffler()
	{
		force_closed = true;
	}

	protected override string getUniqueSaveData()
	{
		return string.Format("{0},{1},{2}", cost, ability_used, force_closed ? "t" : "f");
	}
}
