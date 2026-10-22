using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class OilPlatform : DocksLocationData
{
	private const int min_starting_fuel = 0;

	private const int max_starting_fuel = 3;

	public bool open { get; private set; } = true;

	public int fuel_contained { get; private set; }

	public override LocationTypes location_type => LocationTypes.OIL_PLATFORM;

	protected override string english_name => "Oil Platform";

	protected override string english_description => "The first time the " + Keywords.BOAT.toString() + " is moved onto the " + base.name + ", regain all the " + Keywords.FUEL.toString() + " that is stored there." + $" The {base.name} starts with {0} to {3} {Keywords.FUEL.toString()}.";

	public OilPlatform(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
		open = true;
		fuel_contained = _random.Next(0, 4);
	}

	public OilPlatform(LocationDataSave _save, System.Random _random)
		: base(_save, _random)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			fuel_contained = int.Parse(array[0]);
			open = array[1] == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {location_type}!\nSave: {_save.unique_data}\nError: {arg}");
			open = true;
			fuel_contained = 0;
		}
	}

	protected override string getUniqueSaveData()
	{
		return string.Format("{0},{1}", fuel_contained, open ? "t" : "f");
	}

	public override bool isOfRegion(Regions _region)
	{
		if (_region == Regions.DOCKS)
		{
			return true;
		}
		return false;
	}

	public void increaseFuelStored(int _increase)
	{
		fuel_contained += _increase;
	}

	public override void onBoatMoved(DocksCase _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _new_pos)
	{
		if (open && !(_new_pos != board_position))
		{
			open = false;
			_case.addFuel(fuel_contained);
		}
	}
}
