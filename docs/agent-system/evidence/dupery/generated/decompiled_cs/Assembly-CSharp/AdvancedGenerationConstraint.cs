using System;
using System.Collections.Generic;
using GRGLib.Extensions;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

public abstract class AdvancedGenerationConstraint
{
	public abstract bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects);

	protected bool requireFurtherCheck(DisguiseConstraintType _disguise_constraint, bool _bad_info)
	{
		if (_disguise_constraint != 0)
		{
			return !(_disguise_constraint == DisguiseConstraintType.IGNORE_WHEN_LYING && _bad_info);
		}
		return false;
	}

	protected Func<Vector2Int, Vector2Int, List<Vector2Int>> getPositionFunc(GCPosition _pos_ref)
	{
		return _pos_ref switch
		{
			GCPosition.ADJACENT => (Vector2Int _p, Vector2Int _bs) => _p.getAdjacentPositions(), 
			GCPosition.SURROUNDING => (Vector2Int _p, Vector2Int _bs) => _p.getSurroundingPositions(), 
			GCPosition.NOT_ADJACENT => (Vector2Int _p, Vector2Int _bs) => _p.getNotAdjacentPositions(_bs), 
			GCPosition.NOT_SURROUNDING => (Vector2Int _p, Vector2Int _bs) => _p.getNotSurroundingPositions(_bs), 
			GCPosition.BOARD_EDGE => (Vector2Int _p, Vector2Int _bs) => _bs.getBoardEdgePositions(), 
			GCPosition.BOARD_INNER => (Vector2Int _p, Vector2Int _bs) => _bs.getBoardInnerPositions(), 
			GCPosition.COLUMN => (Vector2Int _p, Vector2Int _bs) => _p.getPositionsInSameColumn(_bs, _include_self: false), 
			GCPosition.ROW => (Vector2Int _p, Vector2Int _bs) => _p.getPositionsInSameRow(_bs, _include_self: false), 
			GCPosition.COLUMN_OR_ROW => (Vector2Int _p, Vector2Int _bs) => _p.getPositionsInSameColumnOrRow(_bs), 
			_ => throw new ArgumentException($"No function set up for GCPosition {_pos_ref} (getPositionFunc)!"), 
		};
	}

	protected Func<Vector2Int, Vector2Int, Vector2Int, bool> isValidPosition(GCPosition _pos_ref)
	{
		return _pos_ref switch
		{
			GCPosition.ADJACENT => (Vector2Int _p, Vector2Int _p2, Vector2Int _bs) => _p.isAdjacent(_p2), 
			GCPosition.SURROUNDING => (Vector2Int _p, Vector2Int _p2, Vector2Int _bs) => _p.isSurroundingOrOn(_p2), 
			GCPosition.NOT_ADJACENT => (Vector2Int _p, Vector2Int _p2, Vector2Int _bs) => !_p.isAdjacent(_p2), 
			GCPosition.NOT_SURROUNDING => (Vector2Int _p, Vector2Int _p2, Vector2Int _bs) => !_p.isSurroundingOrOn(_p2), 
			GCPosition.BOARD_EDGE => (Vector2Int _p, Vector2Int _p2, Vector2Int _bs) => _p2.isEdgePositionOnGrid(_bs), 
			GCPosition.BOARD_INNER => (Vector2Int _p, Vector2Int _p2, Vector2Int _bs) => _p2.isInnerPositionOnGrid(_bs), 
			GCPosition.COLUMN => (Vector2Int _p, Vector2Int _p2, Vector2Int _bs) => _p.x == _p2.x, 
			GCPosition.ROW => (Vector2Int _p, Vector2Int _p2, Vector2Int _bs) => _p.y == _p2.y, 
			GCPosition.COLUMN_OR_ROW => (Vector2Int _p, Vector2Int _p2, Vector2Int _bs) => _p.x == _p2.x || _p.y == _p2.y, 
			_ => throw new ArgumentException($"No function set up for GCPosition {_pos_ref} (isValidPosition)!"), 
		};
	}

	protected bool compareClueTypes(ClueTypes _self, ClueTypes _other)
	{
		return _self switch
		{
			ClueTypes.ROLE_IN_PLAY => _other.equalToAny(ClueTypes.ROLE_IN_PLAY, ClueTypes.ROLE_SUSPECTED), 
			ClueTypes.ROLE_SUSPECTED => _other.equalToAny(ClueTypes.ROLE_IN_PLAY, ClueTypes.ROLE_SUSPECTED), 
			ClueTypes.ROLE_NOT_IN_PLAY => true, 
			_ => throw new ArgumentException($"Cannot compare clue types when self is {_self}! (not set up)"), 
		};
	}
}
