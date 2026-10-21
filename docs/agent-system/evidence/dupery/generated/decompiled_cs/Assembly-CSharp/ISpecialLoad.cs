using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public interface ISpecialLoad
{
	Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseLoaded(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board);
}
