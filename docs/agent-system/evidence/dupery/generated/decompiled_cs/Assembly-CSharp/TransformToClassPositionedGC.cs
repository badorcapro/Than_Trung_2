using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

public class TransformToClassPositionedGC : AdvancedGenerationConstraint, ITransformationGenerationConstraint, IFilterRoleCluesGenerationConstraint, IPositioningGenerationConstraint, ISuspectListRatioGenerationConstraint
{
	public RoleClassifications to_transform;

	public RoleClassifications transform_to;

	private Roles self;

	public GCPosition position;

	public Maybe<Roles> transformed = new Maybe<Roles>();

	public GenerationConstraintPriority position_priority => GenerationConstraintPriority.HIGHEST;

	public TransformToClassPositionedGC(Roles _self, RoleClassifications _to_trans, RoleClassifications _trans_to, GCPosition _position)
	{
		self = _self;
		to_transform = _to_trans;
		transform_to = _trans_to;
		position = _position;
	}

	public bool canBeAddedAsRoleClue(Roles _role, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return true;
	}

	public List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, Roles _self, ClueTypes _self_type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return _roles;
	}

	public HashSet<Roles> addToLeadRoles(Roles _role, HashSet<Roles> _lead_roles, List<Roles> _potential, System.Random _rng)
	{
		return _lead_roles;
	}

	public bool tryTransformation(List<ChainMarker<Roles>> _can_transform, List<ChainMarker<Roles>> _in_play_roles, System.Random _rng, InPlayListFactory _factory, out Maybe<(ChainMarker<Roles>, Roles)> _to_transform)
	{
		List<Roles> list = (from _r in _factory.getSuspectList()
			where _r != self && _r.getClassificationFromRoleType() == RoleClassifications.MEDDLER && _factory.getEmptyRole(_r).getVisualClassification() == RoleClassifications.MEDDLER && !_in_play_roles.Any((ChainMarker<Roles> _ipr) => _ipr.data == _r)
			select _r).ToList();
		if (list.Count == 0)
		{
			_to_transform = new Maybe<(ChainMarker<Roles>, Roles)>();
			return false;
		}
		Roles rep = list.getRandomElementFromList(_rng);
		Maybe<ChainMarker<Roles>> maybe = _can_transform.firstIfSome((ChainMarker<Roles> _m) => _m.data.getClassificationFromRoleType() == to_transform && (!_m.from.is_some || _factory.getEmptyRole(_m.from.value.data).generation_constraint.canReplaceInPlayRole(_factory.getEmptyRole(rep), _m, new Maybe<ChainMarker<Roles>>(), _factory)));
		if (!maybe.is_some)
		{
			_to_transform = new Maybe<(ChainMarker<Roles>, Roles)>();
			return false;
		}
		transformed = rep.maybe();
		_to_transform = (maybe.value, rep).maybe();
		return true;
	}

	public Maybe<Roles> getRoleTransformed(Roles _self, CaseSnapshot _snap)
	{
		return new Maybe<Roles>();
	}

	public List<Vector2Int> filterAvailablePositions(Roles _role, List<Vector2Int> _positions, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, BoardPositioningFactory _factory)
	{
		if (transformed.is_some)
		{
			Maybe<BoardMarker<Roles>> already_positioned = _from.firstIfSome((BoardMarker<Roles> _bm) => _bm.data == transformed.value);
			if (!already_positioned.is_some)
			{
				already_positioned = _positioned_roles.firstIfSome((BoardMarker<Roles> _bm) => _bm.data == transformed.value);
			}
			if (already_positioned.is_some)
			{
				Func<Vector2Int, Vector2Int, Vector2Int, bool> positioning_filter = isValidPosition(position);
				return _positions.Where((Vector2Int _p) => positioning_filter(_p, already_positioned.value.position, _factory.board_size)).ToList();
			}
			return _positions;
		}
		Maybe<BoardMarker<Roles>> ap = _from.firstIfSome((BoardMarker<Roles> _bm) => _bm.data != _role && _bm.data.getClassificationFromRoleType() == transform_to);
		if (!ap.is_some)
		{
			ap = _positioned_roles.firstIfSome((BoardMarker<Roles> _bm) => _bm.data.getClassificationFromRoleType() == transform_to);
		}
		if (ap.is_some)
		{
			Func<Vector2Int, Vector2Int, Vector2Int, bool> positioning_filter2 = isValidPosition(position);
			return _positions.Where((Vector2Int _p) => positioning_filter2(_p, ap.value.position, _factory.board_size)).ToList();
		}
		return _positions;
	}

	public bool tryPositionOther(Roles _role, Vector2Int _position, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, List<Roles> _in_play, BoardPositioningFactory _factory)
	{
		if (transformed.is_some)
		{
			Maybe<BoardMarker<Roles>> maybe = _from.firstIfSome((BoardMarker<Roles> _bm) => _bm.data == transformed.value);
			if (!maybe.is_some)
			{
				maybe = _positioned_roles.firstIfSome((BoardMarker<Roles> _bm) => _bm.data == transformed.value);
			}
			if (maybe.is_some)
			{
				return isValidPosition(position)(maybe.value.position, _position, _factory.board_size);
			}
			return _factory.externalPositionRole(transformed.value, getPositionFunc(position)(_position, _factory.board_size), _from, _lock: true);
		}
		Func<Vector2Int, Vector2Int, Vector2Int, bool> valid_position = isValidPosition(position);
		if (_from.Any((BoardMarker<Roles> _bm) => _bm.data != _role && _bm.data.getClassificationFromRoleType() == transform_to && valid_position(_bm.position, _position, _factory.board_size)))
		{
			return true;
		}
		if (_positioned_roles.Any((BoardMarker<Roles> _bm) => _bm.data.getClassificationFromRoleType() == transform_to && valid_position(_bm.position, _position, _factory.board_size)))
		{
			return true;
		}
		List<Roles> list = _in_play.Where((Roles _r) => _r.getClassificationFromRoleType() == transform_to).ToList();
		if (list.Count == 0)
		{
			return false;
		}
		return _factory.externalPositionAnyRole(list, getPositionFunc(position)(_position, _factory.board_size), _from);
	}

	public Maybe<ValidationError> checkTransformationError(CaseType _type, Roles _self, List<Roles> _in_play, CaseSnapshot _snap)
	{
		return new Maybe<ValidationError>();
	}

	public Maybe<ValidationError> checkPositioningError(CaseType _type, RoleData _self, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseSnapshot _snap, Vector2Int _board_size)
	{
		Func<Vector2Int, Vector2Int, Vector2Int, bool> valid_position = isValidPosition(position);
		if (_board.getRolesInPlayOfClass(transform_to).Any((RoleData _r) => valid_position(_r.getBoardPosition(), _self.getBoardPosition(), _board_size)))
		{
			return new Maybe<ValidationError>();
		}
		return new RequirementPositionedEEB(transform_to, position).createValidationError(_self.role).maybe();
	}

	public Dictionary<RoleClassifications, int> modifySuspectRatio(Dictionary<RoleClassifications, int> _current, Dictionary<RoleClassifications, int> _ratio, SuspectListFactory _factory)
	{
		_current.increaseOrCreate(RoleClassifications.MEDDLER, 1);
		return _current;
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		return !_bad_info;
	}
}
