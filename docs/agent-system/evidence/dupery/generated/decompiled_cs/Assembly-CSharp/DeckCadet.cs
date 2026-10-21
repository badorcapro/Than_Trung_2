using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class DeckCadet : DocksRoleData
{
	private int target_address = -1;

	private int last_said = -1;

	public override Roles role => Roles.DECK_CADET;

	public override string english_name => "Deck Cadet";

	public override string english_description => TextHelper.whenInvestigated + " I choose a random " + TextHelper.pretendingRole + ". I " + Keywords.ANNOUNCE.toString() + " how many " + Keywords.STEPS.toString() + " the " + Keywords.BOAT.toString() + " is from my chosen " + Keywords.ROLE.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I chose a random " + Keywords.ROLE.toString() + " that was " + TextHelper.pretending + " when I was investigated. Even if my chosen " + Keywords.ROLE.toString() + " stops " + TextHelper.pretending + ", I do not pick a new " + Keywords.ROLE.toString() + ".\nIf there are no " + TextHelper.pretendingRoles + ", I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\"."));
			list.Add((DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.ANNOUNCE.toString() + " a random value between 1 and 4. This value can at times point to a " + TextHelper.pretendingRole + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	private string loc_no_info_key => $"{role} [info_no]";

	public DeckCadet(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public DeckCadet(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			target_address = int.Parse(array[0]);
			last_said = int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			target_address = -1;
			last_said = -1;
		}
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type != DescriptionType.SPECIAL)
		{
			return _description;
		}
		return _description.Replace(RoleData.loc_marker_1, checkTranslation(loc_no_info_key, englishInfoNoPretend));
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		if (target_address == -1)
		{
			List<KeyValuePair<int, RoleData>> list = _snap.address_occupents.Where((KeyValuePair<int, RoleData> _r) => _r.Value.getIsDisguised()).ToList();
			if (list.Count == 0)
			{
				target_address = -2;
			}
			else
			{
				target_address = list.getRandomElementFromList(random).Key;
			}
		}
		if (base.has_bad_info)
		{
			last_said = random.Next(1, 5);
			return checkTranslationWithPlural(englishInfo, last_said);
		}
		if (target_address == -2)
		{
			return checkTranslation(loc_no_info_key, englishInfoNoPretend);
		}
		return checkTranslationWithPlural(_replace: last_said = _snap.address_occupents[target_address].getBoardPosition().cardinalDistance(_snap.docks_payload.boat.position), _english: englishInfo);
	}

	private string englishInfo(string _data)
	{
		return "You are " + _data + " step{#/s} away from a suspicious individual.";
	}

	private string englishInfoNoPretend()
	{
		return "The waters are calm.";
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
		return $"{target_address},{last_said}";
	}
}
