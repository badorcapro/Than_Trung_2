using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public interface IAmClockLocation
{
	Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassed(Case _case_ref, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _new_time);
}
