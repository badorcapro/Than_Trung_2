using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Maybe;
using UnityEngine;

public class PositionRoleGC : InPlayRequireRoleGC, IPositioningGenerationConstraint
{
	protected Func<Vector2Int, Vector2Int, List<Vector2Int>> get_wanted;

	protected Func<Vector2Int, Vector2Int, Vector2Int, bool> is_valid_position;

	protected EditorErrorBuilder position_error_builder;

	public virtual GenerationConstraintPriority position_priority => GenerationConstraintPriority.HIGH;

	public PositionRoleGC(Roles _role, GCPosition _position, DisguiseConstraintType _disguise, bool _lock_self = true)
		: base(_role, _disguise, _lock_self)
	{
		Func<Vector2Int, Vector2Int, List<Vector2Int>> positionFunc = getPositionFunc(_position);
		Func<Vector2Int, Vector2Int, Vector2Int, bool> func = isValidPosition(_position);
		EditorErrorBuilder editorErrorBuilder = new RequirementPositionedEEB(_role, _position);
		get_wanted = positionFunc;
		is_valid_position = func;
		position_error_builder = editorErrorBuilder;
	}

	public PositionRoleGC(RoleClassifications _class, GCPosition _position, DisguiseConstraintType _disguise, int _wanted = 1, bool _true_class = false, bool _lock_self = true)
		: base(_class, _wanted, _true_class, _disguise, _lock_self)
	{
		Func<Vector2Int, Vector2Int, List<Vector2Int>> positionFunc = getPositionFunc(_position);
		Func<Vector2Int, Vector2Int, Vector2Int, bool> func = isValidPosition(_position);
		EditorErrorBuilder editorErrorBuilder = new RequirementPositionedEEB(_class, _position);
		get_wanted = positionFunc;
		is_valid_position = func;
		position_error_builder = editorErrorBuilder;
	}

	public PositionRoleGC(RoleClassifications _class, RoleGenerationMarkers _marker, GCPosition _position, DisguiseConstraintType _disguise, int _wanted = 1, bool _true_class = false, bool _lock_self = true)
		: base(_class, _marker, _wanted, _true_class, _disguise, _lock_self)
	{
		Func<Vector2Int, Vector2Int, List<Vector2Int>> positionFunc = getPositionFunc(_position);
		Func<Vector2Int, Vector2Int, Vector2Int, bool> func = isValidPosition(_position);
		EditorErrorBuilder editorErrorBuilder = new RequirementPositionedEEB(_marker, _position);
		get_wanted = positionFunc;
		is_valid_position = func;
		position_error_builder = editorErrorBuilder;
	}

	public PositionRoleGC(RoleGenerationMarkers _marker, GCPosition _position, DisguiseConstraintType _disguise, int _wanted = 1, bool _lock_self = true)
		: base(_marker, _wanted, _disguise, _lock_self)
	{
		Func<Vector2Int, Vector2Int, List<Vector2Int>> positionFunc = getPositionFunc(_position);
		Func<Vector2Int, Vector2Int, Vector2Int, bool> func = isValidPosition(_position);
		EditorErrorBuilder editorErrorBuilder = new RequirementPositionedEEB(_marker, _position);
		get_wanted = positionFunc;
		is_valid_position = func;
		position_error_builder = editorErrorBuilder;
	}

	public PositionRoleGC(GCPosition _position, DisguiseConstraintType _disguise, int _wanted = 1, bool _lock_self = true)
		: base((Roles _r) => true, new RequirementEEB(), _wanted, _disguise, _lock_self)
	{
		Func<Vector2Int, Vector2Int, List<Vector2Int>> positionFunc = getPositionFunc(_position);
		Func<Vector2Int, Vector2Int, Vector2Int, bool> func = isValidPosition(_position);
		EditorErrorBuilder editorErrorBuilder = new RequirementPositionedEEB(_position);
		get_wanted = positionFunc;
		is_valid_position = func;
		position_error_builder = editorErrorBuilder;
	}

	public PositionRoleGC(Func<Roles, bool> _condition, Func<Vector2Int, Vector2Int, List<Vector2Int>> _pos_fetcher, EditorErrorBuilder _error_builder, DisguiseConstraintType _disguise, int _wanted = 1, bool _lock_self = true)
		: base(_condition, _error_builder, _wanted, _disguise, _lock_self)
	{
		Func<Vector2Int, Vector2Int, List<Vector2Int>> func = _pos_fetcher;
		Func<Vector2Int, Vector2Int, Vector2Int, bool> func2 = (Vector2Int _p, Vector2Int _p2, Vector2Int _bs) => _pos_fetcher(_p, _bs).Contains(_p2);
		get_wanted = func;
		is_valid_position = func2;
		position_error_builder = _error_builder;
	}

	public virtual bool tryPositionOther(Roles _role, Vector2Int _position, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, List<Roles> _in_play, BoardPositioningFactory _factory)
	{
		List<Vector2Int> list = get_wanted(_position, _factory.board_size);
		int num = countTargets(_from, list) + countTargets(_positioned_roles, list) + countTargets(_factory.roles_to_position, list);
		if (num >= roles_required)
		{
			return true;
		}
		List<Roles> list2 = _in_play.Where((Roles _r) => _r != _role && is_target(_r) && !_from.Any((BoardMarker<Roles> _m) => _m.data == _r) && !_positioned_roles.Any((BoardMarker<Roles> _m) => _m.data == _r)).ToList();
		if (list2.Count < roles_required - num)
		{
			return false;
		}
		return _factory.externalPositionAnyRole(list2, list, _from, roles_required - num);
	}

	private int countTargets(List<BoardMarker<Roles>> _markers, List<Vector2Int> _positions)
	{
		return _markers.Count((BoardMarker<Roles> _bm) => is_target(_bm.data) && _positions.Contains(_bm.position));
	}

	public List<Vector2Int> filterAvailablePositions(Roles _role, List<Vector2Int> _positions, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, BoardPositioningFactory _factory)
	{
		return _positions;
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		if (!requireFurtherCheck(disguise_constraint, _bad_info))
		{
			return true;
		}
		return _board.getRolesInPlay().Count((KeyValuePair<int, RoleData> _kvp) => is_target(_kvp.Value.role) && is_valid_position(_role.getBoardPosition(), _kvp.Value.getBoardPosition(), _board_size)) >= roles_required;
	}

	public Maybe<ValidationError> checkPositioningError(CaseType _type, RoleData _self, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseSnapshot _snap, Vector2Int _board_size)
	{
		if ((from _r in _board.getRolesInPlay().Values.ToList()
			where _r.role != _self.role && is_target(_r.role) && is_valid_position(_self.getBoardPosition(), _r.getBoardPosition(), _board_size)
			select _r).ToList().Count >= roles_required)
		{
			return new Maybe<ValidationError>();
		}
		return position_error_builder.createValidationError(_self.role).maybe();
	}
}
