using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Clutz : RoleData
{
	private int killed_target = -1;

	public override Roles role => Roles.CLUTZ;

	public override string english_name => "Clutz";

	public override string english_description => "When I am " + TextHelper.arrested + " or " + TextHelper.die + ", I " + Keywords.KILL.toString() + " a random " + Keywords.ROLE.toString() + ". " + TextHelper.ipretendSuspectedInnocent;

	public override bool hasInfo => false;

	public Clutz(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Clutz(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		killed_target = int.Parse(_save.unique_data);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getInnocentDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return ((killed_target == -1) ? "" : (TextHelper.killedOneLocalised(killed_target) + "\n")) + base.getTruthString();
	}

	public override string getUniqueSaveData()
	{
		return killed_target.ToString();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (base.has_bad_info || _arrested_address != base.address)
		{
			return _board;
		}
		killRandomRole(_board);
		return _board;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKillAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		if (base.has_bad_info || _murdered_address != base.address)
		{
			return _board;
		}
		killRandomRole(_board);
		return _board;
	}

	private void killRandomRole(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		RoleData value = (from _r in _board.getRolesInPlay()
			where _r.Value.getAddress() != base.address && !_r.Value.getIsDead() && !_r.Value.getIsArrested()
			select _r).ToList().getRandomElementFromList(random).Value;
		base.case_ref.killAddress(value.getAddress(), ((RoleData)this).maybe());
		killed_target = value.getAddress();
	}
}
