using System;
using Save;
using UnityEngine;

public class Docks : LocationData
{
	public override LocationTypes location_type => LocationTypes.DOCKS;

	protected override string english_name => "Docks";

	protected override string english_description => "Capturing evil on the seas is hard work, expecially when you need to keep an eye on your fuel. Make sure to come back to the docks before it's too late.";

	public Docks(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
	}

	public Docks(LocationDataSave _save, System.Random _random)
		: base(_save, _random)
	{
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}

	public override bool isOfRegion(Regions _region)
	{
		if (_region == Regions.DOCKS)
		{
			return true;
		}
		return false;
	}
}
