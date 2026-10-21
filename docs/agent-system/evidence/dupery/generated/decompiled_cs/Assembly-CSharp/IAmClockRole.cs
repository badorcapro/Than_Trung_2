using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public interface IAmClockRole
{
	Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassed(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _rep, int _new_time);
}
