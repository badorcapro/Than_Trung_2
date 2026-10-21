using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class PriceFixer : CasinoRoleData
{
	private const int cost = 20;

	public override Roles role => Roles.PRICE_FIXER;

	public override string english_name => "Price Fixer";

	public override string english_description => $"While I am {Keywords.ALIVE.toString()} and not {TextHelper.arrested}, you lose an additional {20} {TextHelper.chips_with_link} when {TextHelper.arresting} any {TextHelper.goodRoles} " + Keywords.CARDINALLY_ADJACENT.toString() + " to me. " + TextHelper.iLieAndPretendNotInPlay;

	public override bool hasInfo => false;

	public PriceFixer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public PriceFixer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override int fetchArrestCost(int _arrest_address, int _cost, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload)
	{
		if (_cost == 0 || base.tainted || base.arrested || base.dead || _board.getRolesInPlay()[_arrest_address].getBoardPosition().cardinalDistance(base.board_position) != 1)
		{
			return _cost;
		}
		return _cost + 20;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
