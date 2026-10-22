using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class House : CasinoRoleData
{
	private static int cost_increase = 50;

	public override Roles role => Roles.THE_HOUSE;

	public override string english_name => "House";

	public override string english_description => $"All {Keywords.CHIPS.toString()} costs are increased by {cost_increase}% until I am {TextHelper.arrested} or {TextHelper.killed}. {TextHelper.iLieAndPretendNotInPlay}.";

	public override string credits => "Masser";

	public override bool hasInfo => false;

	public House(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public House(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onMoneySpentAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload, int _money_diff)
	{
		if (_money_diff >= 0 || base.tainted || ((base.dead || base.arrested) && !base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED)))
		{
			return _board;
		}
		base.casino_case.spendChipsSilent(-_money_diff / 2);
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
