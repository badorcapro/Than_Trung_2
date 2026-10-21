using System;
using System.Collections.Generic;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using UnityEngine;

public class PositionSelfGC : AdvancedGenerationConstraint, IPositioningGenerationConstraint
{
	public Func<List<Vector2Int>, Vector2Int, List<Vector2Int>> position_filter;

	protected DisguiseConstraintType disguise_constraint;

	protected EditorErrorBuilder error_builder;

	public GenerationConstraintPriority position_priority => GenerationConstraintPriority.LOW;

	public PositionSelfGC(Func<List<Vector2Int>, Vector2Int, List<Vector2Int>> _filter, EditorErrorBuilder _error_builder, DisguiseConstraintType _disguise)
	{
		position_filter = _filter;
		disguise_constraint = _disguise;
		error_builder = _error_builder;
	}

	public List<Vector2Int> filterAvailablePositions(Roles _role, List<Vector2Int> _positions, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, BoardPositioningFactory _factory)
	{
		return position_filter(_positions, _factory.board_size);
	}

	public bool tryPositionOther(Roles _role, Vector2Int _position, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, List<Roles> _in_play, BoardPositioningFactory _factory)
	{
		return true;
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		if (!requireFurtherCheck(disguise_constraint, _bad_info))
		{
			return true;
		}
		return position_filter(_role.getBoardPosition().makeListFromItem(), _board_size).Count > 0;
	}

	public Maybe<ValidationError> checkPositioningError(CaseType _type, RoleData _self, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseSnapshot _snap, Vector2Int _board_size)
	{
		List<Vector2Int> list = new List<Vector2Int>();
		for (int i = 0; i < _board_size.x; i++)
		{
			for (int j = 0; j < _board_size.y; j++)
			{
				list.Add(new Vector2Int(i, j));
			}
		}
		if (position_filter(list, _board_size).Contains(_self.getBoardPosition()))
		{
			return new Maybe<ValidationError>();
		}
		return error_builder.createValidationError(_self.role).maybe();
	}
}
