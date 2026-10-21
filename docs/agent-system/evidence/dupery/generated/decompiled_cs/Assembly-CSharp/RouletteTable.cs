using System;
using Save;
using UnityEngine;

public class RouletteTable : LocationData
{
	public override LocationTypes location_type => LocationTypes.ROULETTE_TABLE;

	protected override string english_name => "Roulette Table";

	protected override string english_description => "You feeling lucky?";

	public RouletteTable(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
	}

	public RouletteTable(LocationDataSave _save, System.Random _random)
		: base(_save, _random)
	{
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}

	public override bool isOfRegion(Regions _region)
	{
		if (_region == Regions.CASINO)
		{
			return true;
		}
		return false;
	}
}
