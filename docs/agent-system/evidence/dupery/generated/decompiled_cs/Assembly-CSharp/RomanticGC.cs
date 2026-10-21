using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Maybe;
using UnityEngine;

public class RomanticGC : PositionRoleGC
{
	public override GenerationConstraintPriority position_priority => GenerationConstraintPriority.HIGH;

	public RomanticGC()
		: base(RoleClassifications.INNOCENT, GCPosition.ADJACENT, DisguiseConstraintType.IGNORE_WHEN_LYING)
	{
	}

	public override bool tryPositionOther(Roles _role, Vector2Int _position, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, List<Roles> _in_play, BoardPositioningFactory _factory)
	{
		Maybe<BoardMarker<Roles>> casanova = _factory.firstMatch(_from, (BoardMarker<Roles> _m) => _m.data == Roles.CASANOVA);
		if (!casanova.is_some)
		{
			return base.tryPositionOther(_role, _position, _from, _positioned_roles, _positioned_locations, _in_play, _factory);
		}
		List<Vector2Int> potential_pos = (from _p in _position.getAdjacentPositions()
			where _p.isSurroundingOrOn(casanova.value.position)
			select _p).ToList();
		potential_pos.Remove(casanova.value.position);
		if (potential_pos.Count == 0)
		{
			return false;
		}
		Maybe<BoardMarker<Roles>> maybe = _factory.firstMatch(_from, (BoardMarker<Roles> _m) => is_target(_m.data) && potential_pos.Contains(_m.position));
		if (maybe.is_some)
		{
			maybe.value.locked = true;
			return true;
		}
		return _factory.externalPositionAnyRole(_in_play.Where((Roles _r) => is_target(_r)).ToList(), potential_pos, _from);
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		Maybe<RoleData> casanova = _board.getRolesInPlay().Values.ToList().firstIfSome((RoleData _r) => _r.role == Roles.CASANOVA);
		if (!casanova.is_some)
		{
			return base.validateDisguise(_role, _board_size, _bad_info, _board, _suspects);
		}
		return _board.getAdjacentRolesFromGridPos(_role.getBoardPosition(), _board_size).Any((RoleData _r) => _r.getVisualClassification() == RoleClassifications.INNOCENT && _r.getBoardPosition().isSurrounding(casanova.value.getBoardPosition()));
	}
}
