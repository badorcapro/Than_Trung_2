using System;
using Save;
using UnityEngine;

public class BombThreat : LocationData
{
	public override LocationTypes location_type => LocationTypes.BOMB_THREAT;

	protected override string english_name => "Bomb Threat";

	protected override string english_description => "There's been reports of a potential " + LocationTypes.BOMB.toString() + " here! We must be carefull!";

	public BombThreat(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
	}

	public BombThreat(LocationDataSave _save, System.Random _random)
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
