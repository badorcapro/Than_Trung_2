using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class LostAtSea : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.LOST_AT_SEA;

	protected override string english_name => "Lost At Sea";

	protected override string english_description => "The " + Keywords.BOAT.toString() + " starts each " + Keywords.CASE.toString() + " at a random position.";

	public override bool is_case_start_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.DOCKS;
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		DocksCase docks = _case as DocksCase;
		if (docks == null)
		{
			Debug.LogError($"{quirk_type} is a docks only case, dont know what to do in {_case.case_type} region!");
			return _board;
		}
		Dictionary<LocationTypes, LocationData> locationsInPlay = _board.getLocationsInPlay();
		List<Vector2Int> all_pos = _board.Keys.ToList();
		if (locationsInPlay.ContainsKey(LocationTypes.NAVAL_MINE))
		{
			all_pos.Remove(locationsInPlay[LocationTypes.NAVAL_MINE].getBoardPosition());
		}
		docks.doBoatConstructorAction(delegate
		{
			docks.setBoatPositionWithHiddenCheck(all_pos.getRandomElementFromList(_rng));
		});
		return _board;
	}
}
