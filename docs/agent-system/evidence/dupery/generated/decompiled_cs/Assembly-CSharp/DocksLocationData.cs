using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public abstract class DocksLocationData : LocationData, IAmDocksLocation
{
	public DocksLocationData(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
	}

	public DocksLocationData(LocationDataSave _save, System.Random _random)
		: base(_save, _random)
	{
	}

	public virtual void onBoatMoved(DocksCase _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _new_pos)
	{
	}
}
