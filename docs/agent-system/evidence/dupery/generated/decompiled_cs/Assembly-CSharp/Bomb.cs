using System;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Bomb : LocationData
{
	private bool exploded;

	public override LocationTypes location_type => LocationTypes.BOMB;

	protected override string english_name => "Bomb";

	protected override string english_description => "If this blows up, it will take half the neighbourhood with it!";

	public Bomb(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
		setDisguise(LocationTypes.BOMB_THREAT);
	}

	public Bomb(LocationDataSave _save, System.Random _random)
		: base(_save, _random)
	{
		exploded = _save.unique_data == "t";
	}

	public void explode()
	{
		exploded = true;
		disguise = new Maybe<LocationData>();
	}

	protected override string getUniqueSaveData()
	{
		if (!exploded)
		{
			return "";
		}
		return "t";
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
