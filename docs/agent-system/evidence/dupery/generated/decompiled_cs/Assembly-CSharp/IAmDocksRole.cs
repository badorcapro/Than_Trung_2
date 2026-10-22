using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public interface IAmDocksRole
{
	Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMove(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos);

	Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onFuelUsed(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, int _fuel_used);

	Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoleDredged(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, RoleData _dredged, Maybe<RoleData> _dredger);

	Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onPlayerEnd(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload);
}
