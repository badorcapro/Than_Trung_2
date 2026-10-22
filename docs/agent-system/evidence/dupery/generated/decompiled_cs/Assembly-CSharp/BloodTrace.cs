using System;
using Save;
using UnityEngine;

public class BloodTrace : LocationData
{
	public override LocationTypes location_type => LocationTypes.BLOOD_TRACE;

	protected override string english_name => "Blood Trace";

	protected override string english_description => "Someone has cleaned up the " + LocationTypes.CRIME_SCENE.toString() + " but they've missed a spot... Or is this just some blood from another time...";

	public BloodTrace(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
	}

	public BloodTrace(LocationDataSave _save, System.Random _random)
		: base(_save, _random)
	{
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}

	public override bool isOfRegion(Regions _region)
	{
		if (_region == Regions.OFFICE)
		{
			return true;
		}
		return false;
	}
}
