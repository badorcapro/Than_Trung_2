using System;
using System.Collections.Generic;
using Audio;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class NavalMine : DocksLocationData
{
	public const int mine_fuel_damage = 4;

	public bool has_exploded;

	public Maybe<Vector2Int> extra_trigger = new Maybe<Vector2Int>();

	public override LocationTypes location_type => LocationTypes.NAVAL_MINE;

	protected override string english_name => "Naval Mine";

	protected override string english_description => $"If the {Keywords.BOAT.toString()} is ever moved onto this mine, all {TextHelper.adjacentNeighbours} will {TextHelper.die} and you will lose {4} {Keywords.FUEL.toString()}.";

	public NavalMine(System.Random _random, Vector2Int _board_position)
		: base(_random, _board_position)
	{
	}

	public NavalMine(LocationDataSave _save, System.Random _random)
		: base(_save, _random)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			has_exploded = array[0] == "t";
			if (array[1] == "f")
			{
				extra_trigger = new Maybe<Vector2Int>();
			}
			else
			{
				extra_trigger = new Vector2Int(int.Parse(array[1]), int.Parse(array[2])).maybe();
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {location_type}!\nSave: {_save.unique_data}\nError: {arg}");
			has_exploded = false;
			extra_trigger = new Maybe<Vector2Int>();
		}
	}

	protected override string getUniqueSaveData()
	{
		return (has_exploded ? "t" : "f") + "," + (extra_trigger.is_some ? $"{extra_trigger.value.x},{extra_trigger.value.y}" : "f");
	}

	public override bool isOfRegion(Regions _region)
	{
		if (_region == Regions.DOCKS)
		{
			return true;
		}
		return false;
	}

	public override void onBoatMoved(DocksCase _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Vector2Int _new_pos)
	{
		if (!has_exploded && (!(_new_pos != board_position) || (extra_trigger.is_some && !(extra_trigger.value != _new_pos))))
		{
			explodeMine(_case, _board);
		}
	}

	private void explodeMine(DocksCase _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		if (has_exploded)
		{
			Debug.LogError("Mine has already exploded? Can't explode twice!");
			return;
		}
		_case.loseFuel(4);
		foreach (RoleData adjacentRolesFromGridPo in _board.getAdjacentRolesFromGridPos(board_position, _case.board_size))
		{
			_case.killAddress(adjacentRolesFromGridPo.getAddress(), new Maybe<RoleData>());
		}
		has_exploded = true;
		AudioHandler.Sfx.Queuer.addVeto(Sfx.GUNSHOT);
		AudioHandler.Sfx.Queuer.queueSfx(Sfx.NAVAL_MINE_EXPLOSION, 0.7f);
	}

	public void addExtraTrigger(Vector2Int _trigger)
	{
		extra_trigger = _trigger.maybe();
	}
}
