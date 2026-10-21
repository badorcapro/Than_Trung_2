using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class SlotMachine : LocationData, IHaveAbility
{
	public const int base_cost = 15;

	private bool ability_exhausted;

	public string info { get; private set; } = "";

	public override LocationTypes location_type => LocationTypes.SLOT_MACHINE;

	protected override string english_name => "Slot Machine";

	protected override string english_description => "Where some may waste a bit more than just their time.\n<i>Who doesn't like a little gambling...</i>";

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 0;

	public SlotMachine(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
	}

	public SlotMachine(LocationDataSave _save, System.Random _random)
		: base(_save, _random)
	{
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
		if (abilityExhausted)
		{
			return;
		}
		if (!(_case is CasinoCase casinoCase))
		{
			Debug.LogError("Trying to use Slot Machine in a none-casino case!");
			return;
		}
		ability_exhausted = true;
		casinoCase.spendChips(15);
		RoleData roleData = _board.getRolesInPlay().Values.ToList().Find((RoleData _r) => _r.role == Roles.INVESTOR);
		if (roleData == null || !(roleData is Investor investor))
		{
			Debug.LogError("Slot maching with no investor in play!!?");
			info = "No one was tainted";
		}
		else
		{
			info = investor.getNumberTainted();
		}
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}
}
