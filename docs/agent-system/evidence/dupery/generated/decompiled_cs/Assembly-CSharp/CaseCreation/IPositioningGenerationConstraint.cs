using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace CaseCreation;

public interface IPositioningGenerationConstraint
{
	GenerationConstraintPriority position_priority { get; }

	List<Vector2Int> filterAvailablePositions(Roles _role, List<Vector2Int> _positions, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, BoardPositioningFactory _factory);

	bool tryPositionOther(Roles _role, Vector2Int _position, List<BoardMarker<Roles>> _from, List<BoardMarker<Roles>> _positioned_roles, List<BoardMarker<LocationTypes>> _positioned_locations, List<Roles> _in_play, BoardPositioningFactory _factory);

	Maybe<ValidationError> checkPositioningError(CaseType _type, RoleData _self, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseSnapshot _snap, Vector2Int _board_size);
}
