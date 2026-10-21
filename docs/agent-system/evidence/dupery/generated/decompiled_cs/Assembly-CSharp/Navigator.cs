using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Navigator : DocksRoleData
{
	private int wrong_offset;

	public override Roles role => Roles.NAVIGATOR;

	public override string english_name => "Navigator";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " how much " + Keywords.FUEL.toString() + " the " + Keywords.BOAT.toString() + " would need to reach me.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)>
	{
		(DescriptionType.SPECIAL, TextHelper.iAmSelfConfirm),
		(DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves),
		(DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I will " + Keywords.ANNOUNCE.toString() + " a random wrong amount of fuel. The difference to the real value will stay the same the entire case.")
	};

	public override bool hasInfo => true;

	public Navigator(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Navigator(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			wrong_offset = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			wrong_offset = 0;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(default(RoleGenerationMarkers));
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		int num = ((!(_snap.docks_payload.boat.position == base.board_position)) ? _snap.docks_payload.boat.fuelCostToPosition(base.board_position) : 0);
		if (base.has_bad_info)
		{
			if (wrong_offset == 0)
			{
				wrong_offset = random.Next(1, 4);
			}
			return checkTranslationWithData(englishInfo, num + wrong_offset);
		}
		return checkTranslationWithData(englishInfo, num);
	}

	private string englishInfo(string _data)
	{
		return "The boat needs " + _data + " fuel to reach me.";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.dead)
		{
			return _board;
		}
		resetInfo();
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getUniqueSaveData()
	{
		return wrong_offset.ToString();
	}
}
