using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public abstract class CasinoRoleData : RoleData, IAmCasinoRole
{
	public CasinoCase casino_case => base.case_ref as CasinoCase;

	public CasinoRoleData(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public CasinoRoleData(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onMoneySpent(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload, int _money_diff)
	{
		_board = onMoneySpentAction(_board, _payload, _money_diff);
		if (disguise.is_some && disguise.value is IAmCasinoRole amCasinoRole)
		{
			_board = amCasinoRole.onMoneySpent(_board, _payload, _money_diff);
		}
		if (!base.is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(base.board_position, this);
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onMoneySpentAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload, int _money_diff)
	{
		return _board;
	}

	public Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCardDrawn(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload, List<CasinoCard> _discarded, List<CasinoCard> _new_cards)
	{
		_board = onCardDrawnAction(_board, _payload, _discarded, _new_cards);
		if (disguise.is_some && disguise.value is IAmCasinoRole amCasinoRole)
		{
			_board = amCasinoRole.onCardDrawn(_board, _payload, _discarded, _new_cards);
		}
		if (!base.is_true_self)
		{
			return _board;
		}
		return _board.registerRoleChange(base.board_position, this);
	}

	protected virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCardDrawnAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload, List<CasinoCard> _discarded, List<CasinoCard> _new_cards)
	{
		return _board;
	}

	public virtual int fetchInvistigationCost(int _investigating_address, int _cost, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload)
	{
		if (disguise.is_some && disguise.value is IAmCasinoRole amCasinoRole)
		{
			return amCasinoRole.fetchInvistigationCost(_investigating_address, _cost, _board, _payload);
		}
		return _cost;
	}

	public virtual int fetchArrestCost(int _arrest_address, int _cost, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload)
	{
		if (disguise.is_some && disguise.value is IAmCasinoRole amCasinoRole)
		{
			return amCasinoRole.fetchArrestCost(_arrest_address, _cost, _board, _payload);
		}
		return _cost;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (_snap is CasinoCaseSnapshot snap)
		{
			return generateCasinoInfoString(snap);
		}
		Debug.LogError("Snapshot is not a CasinoCaseSnapshot! Cannot regenerate info string!");
		return "";
	}

	protected virtual string generateCasinoInfoString(CasinoCaseSnapshot _snap)
	{
		throw new NotImplementedException("Trying to use generateCasinoInfoString but the function is not set up!");
	}
}
