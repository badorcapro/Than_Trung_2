using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Gossip : RoleData
{
	private int baddie_count = -1;

	public override Roles role => Roles.GOSSIP;

	public override string english_name => "Gossip";

	public override string english_description => TextHelper.whenInvestigated + ", I " + Keywords.ANNOUNCE.toString() + " the number of " + Keywords.S_NEIGHBOURS.toString() + " an " + TextHelper.evilRole + " has.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a random number of " + Keywords.S_NEIGHBOURS.toString() + " that no " + TextHelper.evilRole + " has."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public override bool has_end_info_hover_focus => true;

	private string loc_info_key => $"{role} [info]";

	public Gossip(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Gossip(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		baddie_count = int.Parse(_save.unique_data);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (!base.has_bad_info && base.case_ref.hasMarkerQuirk(CaseQuirks.DARK_WHISPERS))
		{
			List<int> list = (from _e in _snap.board.getRolesInPlay().Values
				where _e.getVisualClassification() == RoleClassifications.TRAITOR
				select _snap.board.getSurroundingRolesFromGridPos(_e.getBoardPosition(), base.case_ref.board_size).Count).ToList();
			if (list.Count != 0)
			{
				list.shuffle(random);
				baddie_count = list[0];
				return infoString(baddie_count);
			}
		}
		List<int> baddie_neighbours = (from _e in _snap.board.getRolesInPlay().Values
			where _e.getVisualAlignment() == Alignments.EVIL
			select _snap.board.getSurroundingRolesFromGridPos(_e.getBoardPosition(), base.case_ref.board_size).Count).ToList();
		if (base.has_bad_info)
		{
			List<int> list2 = (from _e in _snap.board.getRolesInPlay().Values
				where _e.getVisualAlignment() == Alignments.GOOD
				select _snap.board.getSurroundingRolesFromGridPos(_e.getBoardPosition(), base.case_ref.board_size).Count into _c
				where !baddie_neighbours.Contains(_c)
				select _c).ToList();
			if (list2.Count > 0)
			{
				list2.shuffle(random);
				baddie_count = list2[0];
				return infoString(baddie_count);
			}
			List<int> list3 = new List<int> { 0, 1, 2, 3, 4, 5, 6, 7, 8 }.removeAll((int _n) => baddie_neighbours.Contains(_n));
			if (list3.Count == 0)
			{
				baddie_count = 9;
				return infoString(9);
			}
			int index = random.Next(0, Mathf.Min(list3.Count, 3));
			baddie_count = list3[index];
			return infoString(baddie_count);
		}
		baddie_count = baddie_neighbours.getRandomElementFromList(random);
		return infoString(baddie_count);
	}

	private string infoString(int _neighbours)
	{
		return checkTranslationWithPlural(loc_info_key, getInfoEnglish, _neighbours);
	}

	private string getInfoEnglish(string _data)
	{
		return "I heard that a strange guy in town has " + _data + " neighbour{#/s}.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return _snap.board.getSurroundingRolesFromGridPos(_position, base.case_ref.board_size).Count == baddie_count;
	}

	public override bool checkEndInfoHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (base.has_bad_info)
		{
			return checkHoverFocus(_snap, _position, _occupent);
		}
		if (!_occupent.is_a || _occupent.maybe_a.value.getVisualAlignment() != Alignments.EVIL)
		{
			return false;
		}
		return _snap.board.getSurroundingRolesFromGridPos(_position, base.case_ref.board_size).Count == baddie_count;
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	public override string getUniqueSaveData()
	{
		return baddie_count.ToString();
	}
}
