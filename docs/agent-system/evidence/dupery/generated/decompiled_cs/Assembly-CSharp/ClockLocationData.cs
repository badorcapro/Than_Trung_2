using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public abstract class ClockLocationData : LocationData, IAmClockLocation
{
	public ClockLocationData(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
	}

	public ClockLocationData(LocationDataSave _save, System.Random _random)
		: base(_save, _random)
	{
	}

	public virtual Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassed(Case _case_ref, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _new_time)
	{
		return _board;
	}
}
