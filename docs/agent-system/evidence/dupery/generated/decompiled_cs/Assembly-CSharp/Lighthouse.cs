using System;
using Save;
using UnityEngine;

public class Lighthouse : LocationData
{
	public override LocationTypes location_type => LocationTypes.LIGHTHOUSE;

	protected override string english_name => "Lighthouse";

	protected override string english_description => "Shines bright for all ships in the docks to see.";

	public Lighthouse(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
	}

	public Lighthouse(LocationDataSave _save, System.Random _random)
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
