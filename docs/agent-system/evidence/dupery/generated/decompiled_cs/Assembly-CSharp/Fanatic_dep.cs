using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Fanatic_dep : RoleData
{
	private int fanatic_num = -1;

	public override Roles role => Roles.S_FANATIC;

	public override string english_name => "Fanatic";

	public override string english_description => "I pick a " + Keywords.TARGET.toString() + ". If my " + Keywords.TARGET.toString() + " " + TextHelper.dies + ", I " + TextHelper.die + ". If my " + Keywords.TARGET.toString() + " is " + TextHelper.arrested + ", I " + TextHelper.die + ". If I " + TextHelper.die + ", you lose one " + Keywords.REPUTATION.toString() + ".";

	public override bool hasInfo => false;

	public Fanatic_dep(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		fanatic_num = int.Parse(_save.unique_data);
	}

	public Fanatic_dep(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getUniqueSaveData()
	{
		return fanatic_num.ToString();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.MEDDLER;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		fanatic_num = _board.getRolesInPlay().Values.Select((RoleData _e) => (_e: _e, (_e.role.getClassificationFromRoleType() == RoleClassifications.INNOCENT || _e.role.getClassificationFromRoleType() == RoleClassifications.MEDDLER) ? 8 : ((_e.role.getClassificationFromRoleType() == RoleClassifications.UNDERLING) ? 4 : 2))).ToList().weightedChoose(random)
			.value.getAddress();
		return _board;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address == fanatic_num && !base.has_bad_info && !getIsDead() && !getIsArrested())
		{
			_board = base.case_ref.killAddress(base.address, ((RoleData)this).maybe()).board;
		}
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKillAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		if (_murdered_address == getAddress() && !base.has_bad_info && !getIsArrested())
		{
			if (_payload is ClockCaseActionPayload clockCaseActionPayload && base.case_ref is ClockCase clockCase)
			{
				clockCase.setReputationExternally(clockCaseActionPayload.reputation - 1);
			}
			else if (_payload is DocksCaseActionPayload docksCaseActionPayload && base.case_ref is DocksCase docksCase)
			{
				docksCase.setReputationExternally(docksCaseActionPayload.reputation - 1);
			}
			else
			{
				Debug.LogError($"{role} onKillAction is not set up for given payload! {_payload.GetType()}! Cast Type: {base.case_ref.case_type}");
			}
		}
		if (_murdered_address == fanatic_num && !base.has_bad_info && !getIsDead() && !getIsArrested())
		{
			_board = base.case_ref.killAddress(base.address, ((RoleData)this).maybe()).board;
		}
		return base.onKillAction(_board, _payload, _murdered_address, _killer);
	}
}
