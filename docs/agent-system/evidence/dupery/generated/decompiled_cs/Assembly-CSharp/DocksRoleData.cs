using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public abstract class DocksRoleData : RoleData, IAmDocksRole
{
	public DocksCase docks_case => base.case_ref as DocksCase;

	public DocksRoleData(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public DocksRoleData(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMove(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		_board = onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
		if (disguise.is_some && disguise.value is IAmDocksRole amDocksRole)
		{
			_board = amDocksRole.onBoatMove(_board, _payload, _old_pos, _new_pos);
		}
		if (!base.is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(base.board_position, this);
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		return _board;
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onFuelUsed(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, int _fuel_used)
	{
		_board = onFuelUsedAction(_board, _payload, _fuel_used);
		if (disguise.is_some && disguise.value is IAmDocksRole amDocksRole)
		{
			_board = amDocksRole.onFuelUsed(_board, _payload, _fuel_used);
		}
		if (!base.is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(base.board_position, this);
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onFuelUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, int _fuel_used)
	{
		return _board;
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoleDredged(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, RoleData _dredged, Maybe<RoleData> _dredger)
	{
		_board = onRoleDredgedAction(_board, _payload, _dredged, _dredger);
		if (disguise.is_some && disguise.value is IAmDocksRole amDocksRole)
		{
			_board = amDocksRole.onRoleDredged(_board, _payload, _dredged, _dredger);
		}
		if (!base.is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(base.board_position, this);
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoleDredgedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, RoleData _dredged, Maybe<RoleData> _dredger)
	{
		return _board;
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onPlayerEnd(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload)
	{
		_board = onPlayerEndAction(_board, _payload);
		if (disguise.is_some && disguise.value is IAmDocksRole amDocksRole)
		{
			_board = amDocksRole.onPlayerEnd(_board, _payload);
		}
		if (!base.is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(base.board_position, this);
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onPlayerEndAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload)
	{
		return _board;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (_snap is DocksCaseSnapshot snap)
		{
			return generateDocksInfoString(snap);
		}
		Debug.LogError("Snapshot is not a DocksCaseSnapshot! Cannot regenerate info string!");
		return "";
	}

	protected virtual string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		throw new NotImplementedException("Trying to use generateClockInfoString but the function is not set up!");
	}
}
