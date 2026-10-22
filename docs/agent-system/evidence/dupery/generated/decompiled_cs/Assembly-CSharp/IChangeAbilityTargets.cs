using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public interface IChangeAbilityTargets
{
	List<int> changeAbilityTargets(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<int> _targets, int _abil_user_address);

	List<AbilityData> changeAbilityData(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<AbilityData> _data, int _abil_user_address);
}
