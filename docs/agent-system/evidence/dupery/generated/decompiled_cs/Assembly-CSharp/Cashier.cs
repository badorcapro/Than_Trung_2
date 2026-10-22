using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Cashier : CasinoRoleData
{
	private string hide_id => $"#{role}";

	public override Roles role => Roles.CASHIER;

	public override string english_name => "Cashier";

	public override string english_description => "While I am " + Keywords.ALIVE.toString() + " and " + Keywords.UNARRESTED.toString() + ", the number of " + TextHelper.chips_with_link + " you own is hidden. " + TextHelper.iLieAndPretendSuspected + ".";

	public override string credits => "Proker10ias";

	public override bool hasInfo => false;

	public Cashier(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Cashier(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return "";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted)
		{
			return _board;
		}
		base.casino_case.hideChips(hide_id);
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address != base.address || base.tainted)
		{
			return _board;
		}
		base.casino_case.revealChips(hide_id);
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKillAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		if (_murdered_address != base.address || base.tainted)
		{
			return _board;
		}
		base.casino_case.revealChips(hide_id);
		return base.onKillAction(_board, _payload, _murdered_address, _killer);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
