using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public interface IAmDocksLocation
{
	void onBoatMoved(DocksCase _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _new_pos);
}
