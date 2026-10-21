using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public interface IChangeReputationStatus
{
	ReputationStatus checkVisualReputation(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _reputation, ReputationStatus _current_visual);
}
