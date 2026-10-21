using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public abstract class BackAlleyRoleData : RoleData, IAmBackAlleyRole
{
	public BackAlleysCase back_alley_case => base.case_ref as BackAlleysCase;

	public BackAlleyRoleData(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public BackAlleyRoleData(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onItemUsed(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCaseActionPayload _payload, BackAlleySlot _item_slot)
	{
		_board = onItemUsedAction(_board, _payload, _item_slot);
		if (disguise.is_some && disguise.value is IAmBackAlleyRole amBackAlleyRole)
		{
			_board = amBackAlleyRole.onItemUsed(_board, _payload, _item_slot);
		}
		if (!base.is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(base.board_position, this);
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onItemUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCaseActionPayload _payload, BackAlleySlot _item_slot)
	{
		return _board;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (_snap is BackAlleysCaseSnapshot snap)
		{
			return generateBackAlleysInfoString(snap);
		}
		Debug.LogError("Snapshot is not a BackAlleysCaseSnapshot! Cannot regenerate info string!");
		return "";
	}

	protected virtual string generateBackAlleysInfoString(BackAlleysCaseSnapshot _snap)
	{
		throw new NotImplementedException("Trying to use generateBackAlleysInfoString but the function is not set up!");
	}
}
