using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Barrelman : DocksRoleData
{
	private int last_said = -1;

	public override Roles role => Roles.BARRELMAN;

	public override string english_name => "Barrelman";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " how many " + Keywords.STEPS.toString() + " the " + Keywords.BOAT.toString() + " is from the furthest " + TextHelper.evilRole + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)>
	{
		(DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves),
		(DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.ANNOUNCE.toString() + " a random value between 1 and 6 that is incorrect.")
	};

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public Barrelman(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Barrelman(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		last_said = RoleHelper.tryLoadSingleValueFromUniqueData(role, _save);
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		int num = (last_said = _snap.address_occupents.Where((KeyValuePair<int, RoleData> _r) => _r.Value.getVisualAlignment() == Alignments.EVIL).Aggregate(0, (int _a, KeyValuePair<int, RoleData> _r) => Mathf.Max(_a, _r.Value.getBoardPosition().cardinalDistance(_snap.docks_payload.boat.position))));
		if (base.has_bad_info)
		{
			int num2 = (_snap.docks_payload.boat.position.isInnerPositionOnGrid(base.case_ref.board_size) ? 4 : 6);
			last_said = random.Next(1, num2 + 1);
			if (last_said == num)
			{
				last_said = last_said % num2 + 1;
			}
		}
		return checkTranslationWithPlural(englishInfo, last_said);
	}

	private string englishInfo(string _data)
	{
		return "The furthest evil is " + _data + " step{#/s} from the boat.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!(_snap.payload is DocksCaseActionPayload docksCaseActionPayload))
		{
			Debug.LogError($"Trying to check hover focus for role in the wrong region!!! {role}!");
			return false;
		}
		if (_position.cardinalDistance(docksCaseActionPayload.boat.position) == last_said)
		{
			return _occupent.is_a;
		}
		return false;
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
		return $"{last_said}";
	}
}
