using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

public class CasanovaGC : InPlayRequireRoleGC, IPositioningGenerationConstraint
{
	private Roles other_role;

	public GenerationConstraintPriority position_priority => GenerationConstraintPriority.HIGHEST;

	public CasanovaGC(Roles _other = Roles.ROMANTIC)
		: base(_other, DisguiseConstraintType.ALWAYS_IGNORE)
	{
		other_role = _other;
		allow_suspect_ratio_increase = true;
	}

	public List<Vector2Int> filterAvailablePositions(Roles _role, List<Vector2Int> _positions, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, BoardPositioningFactory _factory)
	{
		Maybe<BoardMarker<Roles>> other_pos = _factory.firstMatch(_from, (BoardMarker<Roles> _m) => _m.data == other_role);
		if (!other_pos.is_some)
		{
			return _positions;
		}
		List<Vector2Int> other_innocent_neighbours = _positioned_roles.whereSelect((BoardMarker<Roles> _r) => _factory.getVisualClass(_r.data) == RoleClassifications.INNOCENT && _r.position.isAdjacent(other_pos.value.position), (BoardMarker<Roles> _m) => _m.position);
		return _positions.Where((Vector2Int _p) => other_innocent_neighbours.Any((Vector2Int _ip) => _ip.isSurroundingOrOn(_p))).ToList();
	}

	public bool tryPositionOther(Roles _role, Vector2Int _position, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, List<Roles> _in_play, BoardPositioningFactory _factory)
	{
		Maybe<BoardMarker<Roles>> maybe = _factory.firstMatch(_from, (BoardMarker<Roles> _m) => _m.data == other_role);
		if (maybe.is_some)
		{
			List<Vector2Int> potential_partners = (from _p in maybe.value.position.getAdjacentPositions()
				where _p.isSurroundingOrOn(_position)
				select _p).ToList();
			if (potential_partners.Count == 0)
			{
				return false;
			}
			if (_factory.firstMatch(_from, (BoardMarker<Roles> _m) => potential_partners.Contains(_m.position) && _factory.getVisualClass(_m.data) == RoleClassifications.INNOCENT).is_some)
			{
				return true;
			}
			return _factory.externalPositionAnyRole(_in_play.Where((Roles _i) => _factory.getVisualClass(_i) == RoleClassifications.INNOCENT).ToList(), potential_partners, _from);
		}
		HashSet<Vector2Int> hashSet = _position.getSurroundingPositions().Aggregate(new HashSet<Vector2Int>(), (HashSet<Vector2Int> _a, Vector2Int _p) => (!_factory.hasSomethingAtPosition(_from, _p)) ? _a.addRange(_p.getAdjacentPositions()) : _a);
		hashSet.Remove(_position);
		return _factory.externalPositionRole(other_role, hashSet.ToList(), _from, _lock: true);
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		return true;
	}

	public override List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, Roles _self, ClueTypes _self_type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		switch (_self_type)
		{
		case ClueTypes.ROLE_NOT_IN_PLAY:
			return _roles;
		case ClueTypes.ROLE_IN_PLAY:
			return _roles.remove(other_role);
		default:
			if (_type == ClueTypes.ROLE_NOT_IN_PLAY)
			{
				return _roles.remove(other_role);
			}
			return _roles;
		}
	}

	public override bool canBeAddedAsRoleClue(Roles _role, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_type == ClueTypes.ROLE_NOT_IN_PLAY)
		{
			return true;
		}
		if (_forced.getOrCreate(ClueTypes.ROLE_NOT_IN_PLAY, () => new List<Roles>()).Contains(other_role))
		{
			return false;
		}
		if (!_unforced.Contains(other_role))
		{
			return _forced.getOrCreate(_type, () => new List<Roles>()).Contains(other_role);
		}
		return true;
	}

	public Maybe<ValidationError> checkPositioningError(CaseType _type, RoleData _self, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseSnapshot _snap, Vector2Int _board_size)
	{
		List<RoleData> l = _board.getRolesInPlay().Values.ToList();
		Maybe<RoleData> other_in_play = l.firstIfSome((RoleData _r) => _r.role == other_role);
		if (!other_in_play.is_some)
		{
			return new RequirementEEB(other_role).createValidationError(_self.role).maybe();
		}
		if ((from _r in _board.getSurroundingRolesFromGridPos(_self.getBoardPosition(), _board_size)
			where _r.getVisualClassification() == RoleClassifications.INNOCENT
			select _r).Any((RoleData _r) => _r.getBoardPosition().isAdjacent(other_in_play.value.getBoardPosition())))
		{
			return new Maybe<ValidationError>();
		}
		return new SpecialEEB(SpecialEEB.SpecialErrors.CASANOVA_SPECIAL).createValidationError(_self.role).maybe();
	}
}
