using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public interface IAmBackAlleyRole
{
	Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onItemUsed(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, BackAlleysCaseActionPayload _payload, BackAlleySlot _item_slot);
}
