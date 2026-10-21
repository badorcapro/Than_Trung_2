using System;
using Save;
using UnityEngine;

public class CrimeScene : LocationData
{
	public override LocationTypes location_type => LocationTypes.CRIME_SCENE;

	protected override string english_name => "Crime Scene";

	protected override string english_description => "Where it all started... The syndicate must be stopped!";

	public CrimeScene(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
	}

	public CrimeScene(LocationDataSave _save, System.Random _random)
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
			return false;
		}
		return true;
	}
}
