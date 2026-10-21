using System;
using GRGLib.Serializable;
using UnityEngine;

namespace Save;

[Serializable]
public class LocationDataSave
{
	public LocationTypes location_type;

	public STupple<int, int> board_position;

	public string unique_data;

	public LocationDataSave(LocationTypes _type, Vector2Int _board_position, string _unique_data)
	{
		location_type = _type;
		board_position = new STupple<int, int>(_board_position.x, _board_position.y);
		unique_data = _unique_data;
	}
}
