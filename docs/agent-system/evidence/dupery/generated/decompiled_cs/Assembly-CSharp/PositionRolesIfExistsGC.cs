using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Maybe;
using UnityEngine;

public class PositionRolesIfExistsGC : AdvancedGenerationConstraint, IPositioningGenerationConstraint
{
	protected Roles[] to_position;

	protected DisguiseConstraintType disguise_constraint;

	protected GCPosition position;

	protected Func<Vector2Int, Vector2Int, List<Vector2Int>> get_wanted;

	protected Func<Vector2Int, Vector2Int, Vector2Int, bool> is_valid_position;

	public GenerationConstraintPriority position_priority => GenerationConstraintPriority.MEDIUM;

	public PositionRolesIfExistsGC(GCPosition _position, DisguiseConstraintType _disguise, params Roles[] _roles)
	{
		Func<Vector2Int, Vector2Int, List<Vector2Int>> positionFunc = getPositionFunc(_position);
		Func<Vector2Int, Vector2Int, Vector2Int, bool> func = isValidPosition(_position);
		to_position = _roles;
		disguise_constraint = _disguise;
		position = _position;
		get_wanted = positionFunc;
		is_valid_position = func;
	}

	public List<Vector2Int> filterAvailablePositions(Roles _role, List<Vector2Int> _positions, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, BoardPositioningFactory _factory)
	{
		return _positions;
	}

	public bool tryPositionOther(Roles _role, Vector2Int _position, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, List<Roles> _in_play, BoardPositioningFactory _factory)
	{
		List<Roles> list = to_position.Where((Roles _r) => _in_play.Contains(_r)).ToList();
		if (list.Count == 0)
		{
			return true;
		}
		return _factory.externalPositionAnyRole(list, get_wanted(_position, _factory.board_size), _from, list.Count);
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		if (!requireFurtherCheck(disguise_constraint, _bad_info))
		{
			return true;
		}
		return _board.getRolesInPlay().All((KeyValuePair<int, RoleData> _r) => !to_position.Contains(_r.Value.role) || is_valid_position(_role.getBoardPosition(), _r.Value.getBoardPosition(), _board_size));
	}

	public Maybe<ValidationError> checkPositioningError(CaseType _type, RoleData _self, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseSnapshot _snap, Vector2Int _board_size)
	{
		List<KeyValuePair<int, RoleData>> list = (from _kvp in _board.getRolesInPlay()
			where to_position.Contains(_kvp.Value.role)
			select _kvp).ToList();
		if (list.Count == 0)
		{
			return new Maybe<ValidationError>();
		}
		Maybe<KeyValuePair<int, RoleData>> maybe = list.firstIfSome((KeyValuePair<int, RoleData> _tc) => !is_valid_position(_self.getBoardPosition(), _tc.Value.getBoardPosition(), _board_size));
		if (!maybe.is_some)
		{
			return new Maybe<ValidationError>();
		}
		return new RequirementPositionedEEB(maybe.value.Value.role, position).createValidationError(_self.role).maybe();
	}
}
