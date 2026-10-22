using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public interface IChangeReputation
{
	int checkReputationChange(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _rep_change);
}
