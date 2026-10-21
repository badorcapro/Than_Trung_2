using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

public interface IAmCasinoRole
{
	Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onMoneySpent(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload, int _money_diff);

	Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCardDrawn(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload, List<CasinoCard> _discarded, List<CasinoCard> _new_cards);

	int fetchInvistigationCost(int _investigating_address, int _cost, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload);

	int fetchArrestCost(int _arrest_address, int _cost, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload);
}
