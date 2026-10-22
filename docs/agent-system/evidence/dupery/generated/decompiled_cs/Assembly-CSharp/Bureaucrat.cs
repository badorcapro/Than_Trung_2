using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Bureaucrat : ClockRoleData
{
	private const int arresting_time = 2;

	public override Roles role => Roles.BUREAUCRAT;

	public override string english_name => "Bureaucrat";

	public override string english_description => $"{TextHelper.whileIAmAliveAndNotArrested}, {TextHelper.arresting} a {Keywords.ROLE.toString()} takes an additional {2} hours. {TextHelper.iLieAndPretendSuspected}.";

	public override string credits => "catsKats (camosia)";

	public override bool hasInfo => false;

	public Bureaucrat(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Bureaucrat(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
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

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (base.arrested || base.dead || base.tainted)
		{
			return _board;
		}
		base.clock_case.waitTime(2);
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
