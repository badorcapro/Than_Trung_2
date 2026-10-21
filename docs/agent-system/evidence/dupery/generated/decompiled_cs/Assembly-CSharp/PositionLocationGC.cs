using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Maybe;
using UnityEngine;

public class PositionLocationGC : InPlayLocationGC, IPositioningGenerationConstraint
{
	protected Func<Vector2Int, Vector2Int, List<Vector2Int>> get_wanted;

	protected Func<Vector2Int, Vector2Int, Vector2Int, bool> is_valid_position;

	public GenerationConstraintPriority position_priority => GenerationConstraintPriority.MEDIUM;

	public PositionLocationGC(LocationTypes _loc, GCPosition _position, DisguiseConstraintType _disguise)
		: base(_loc, _disguise)
	{
		Func<Vector2Int, Vector2Int, List<Vector2Int>> positionFunc = getPositionFunc(_position);
		Func<Vector2Int, Vector2Int, Vector2Int, bool> func = isValidPosition(_position);
		EditorErrorBuilder editorErrorBuilder = new RequirementPositionedEEB(_loc, _position);
		get_wanted = positionFunc;
		is_valid_position = func;
		error_builder = editorErrorBuilder;
	}

	public PositionLocationGC(LocationTypes _loc, Func<Vector2Int, Vector2Int, List<Vector2Int>> _pos_fetcher, EditorErrorBuilder _error_builder, DisguiseConstraintType _disguise)
		: this(_loc, _pos_fetcher, (Vector2Int _p, Vector2Int _p2, Vector2Int _bs) => _pos_fetcher(_p, _bs).Contains(_p2), _error_builder, _disguise)
	{
	}

	public PositionLocationGC(LocationTypes _loc, Func<Vector2Int, Vector2Int, List<Vector2Int>> _pos_fetcher, Func<Vector2Int, Vector2Int, Vector2Int, bool> _validify, EditorErrorBuilder _error_builder, DisguiseConstraintType _disguise)
		: base(_loc, _disguise)
	{
		get_wanted = _pos_fetcher;
		is_valid_position = _validify;
		error_builder = _error_builder;
	}

	public List<Vector2Int> filterAvailablePositions(Roles _role, List<Vector2Int> _positions, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, BoardPositioningFactory _factory)
	{
		Maybe<BoardMarker<LocationTypes>> positioned_loc = _positioned_locations.firstIfSome((BoardMarker<LocationTypes> _m) => _m.data == location_to_add);
		if (!positioned_loc.is_some)
		{
			return _positions;
		}
		return _positions.Where((Vector2Int _p) => is_valid_position(_p, positioned_loc.value.position, _factory.board_size)).ToList();
	}

	public bool tryPositionOther(Roles _role, Vector2Int _position, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, List<Roles> _in_play, BoardPositioningFactory _factory)
	{
		List<Vector2Int> list = get_wanted(_position, _factory.board_size);
		Maybe<BoardMarker<LocationTypes>> maybe = _positioned_locations.firstIfSome((BoardMarker<LocationTypes> _m) => _m.data == location_to_add);
		if (maybe.is_some)
		{
			return list.Contains(maybe.value.position);
		}
		return _factory.externalPositionLocation(location_to_add, list, _from, _lock: true);
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		if (!requireFurtherCheck(disguise_constraint, _bad_info))
		{
			return true;
		}
		Dictionary<LocationTypes, LocationData> locationsInPlay = _board.getLocationsInPlay();
		if (!locationsInPlay.ContainsKey(location_to_add))
		{
			return false;
		}
		return is_valid_position(_role.getBoardPosition(), locationsInPlay[location_to_add].getBoardPosition(), _board_size);
	}

	public Maybe<ValidationError> checkPositioningError(CaseType _type, RoleData _self, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseSnapshot _snap, Vector2Int _board_size)
	{
		Dictionary<LocationTypes, LocationData> locationsInPlay = _board.getLocationsInPlay();
		if (locationsInPlay.ContainsKey(location_to_add) && is_valid_position(_self.getBoardPosition(), locationsInPlay[location_to_add].getBoardPosition(), _board_size))
		{
			return new Maybe<ValidationError>();
		}
		return error_builder.createValidationError(_self.role).maybe();
	}
}
