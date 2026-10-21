using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using UnityEngine;

public class DocksBoat
{
	public Vector2Int position;

	public int fuel;

	public int max_fuel;

	public bool fuel_hidden;

	public Maybe<int> fuel_offset = new Maybe<int>();

	public List<Func<DocksBoat, Vector2Int, int>> fuel_cost_changes = new List<Func<DocksBoat, Vector2Int, int>>();

	public int visual_fuel => fuel + (fuel_offset.is_some ? fuel_offset.value : 0);

	public int visual_max_fuel => fuel + (fuel_offset.is_some ? fuel_offset.value : 0);

	public DocksBoat(int _starting_fuel, Vector2Int _start_position)
	{
		position = _start_position;
		fuel = _starting_fuel;
		max_fuel = _starting_fuel;
	}

	public DocksBoat(string _save)
	{
		try
		{
			string[] array = _save.Split('#');
			position = new Vector2Int(int.Parse(array[0]), int.Parse(array[1]));
			fuel = int.Parse(array[2]);
			max_fuel = int.Parse(array[3]);
			fuel_hidden = array[4] == "t";
			fuel_offset = ((array[5] == "f") ? new Maybe<int>() : int.Parse(array[5]).maybe());
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading failed! DocksBoat! Error: {arg}");
			position = new Vector2Int(0, 0);
			fuel = 1;
			max_fuel = 10;
			fuel_hidden = false;
			fuel_offset = new Maybe<int>();
		}
	}

	public int fuelCostToPosition(Vector2Int _pos)
	{
		return 1 + position.cardinalDistance(_pos) + fuel_cost_changes.Aggregate(0, (int _a, Func<DocksBoat, Vector2Int, int> _f) => _a + _f(this, _pos));
	}

	public int estimateFuelCostToPosition(Vector2Int _pos)
	{
		return 1 + position.cardinalDistance(_pos);
	}

	public int estimateFuelCostToPosition(Vector2Int _from, Vector2Int _to)
	{
		return 1 + _from.cardinalDistance(_to);
	}

	public string toSave()
	{
		return string.Format("{0}#{1}#{2}#{3}#{4}#{5}", position.x, position.y, fuel, max_fuel, fuel_hidden ? "t" : "f", fuel_offset.is_some ? fuel_offset.value.ToString() : "f");
	}
}
