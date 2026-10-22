using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Taciturn : ClockRoleData
{
	private const int extra_hours = 2;

	public override Roles role => Roles.TACITURN;

	public override string english_name => "Taciturn";

	public override string english_description => $"When {TextHelper.investigated} an extra {2} hours pass. {TextHelper.iLieAndPretendSuspected}.";

	public override bool hasInfo => false;

	public Taciturn(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Taciturn(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (_investigated_address != base.address || base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
