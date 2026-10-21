using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public interface IHaveMultiAbility : IHaveSpecialAbility, IHaveAbility
{
	List<IHaveAbility> abilities { get; }

	new void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data);
}
