using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public abstract class ClockRoleData : RoleData, IAmClockRole
{
	public ClockCase clock_case => base.case_ref as ClockCase;

	public ClockRoleData(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public ClockRoleData(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassed(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _rep, int _new_time)
	{
		_board = onTimePassedAction(_board, _rep, _new_time);
		if (disguise.is_some && disguise.value is IAmClockRole amClockRole)
		{
			_board = amClockRole.onTimePassed(_board, _rep, _new_time);
		}
		if (!base.is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(base.board_position, this);
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _rep, int _new_time)
	{
		return _board;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (_snap is ClockCaseSnapshot snap)
		{
			return generateClockInfoString(snap);
		}
		Debug.LogError($"Snapshot is not a ClockCaseSnapshot! Cannot regenerate info string! ({role})");
		return "";
	}

	protected virtual string generateClockInfoString(ClockCaseSnapshot _snap)
	{
		throw new NotImplementedException("Trying to use generateClockInfoString but the function is not set up!");
	}
}
