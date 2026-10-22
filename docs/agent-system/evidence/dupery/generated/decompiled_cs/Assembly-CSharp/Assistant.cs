using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Assistant : RoleData
{
	private List<int> parts = new List<int>();

	public override Roles role => Roles.ASSISTANT;

	public override string english_name => "Assistant";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " how many " + TextHelper.evilRoles + " live at an " + Keywords.ADDRESS.toString() + " that is higher than my own.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a random number between 0 and the number of " + Keywords.IN_PLAY.toString() + " " + TextHelper.evilRoles + " that is incorrect."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public override bool has_end_info_hover_focus => parts.Count > 0;

	public Assistant(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Assistant(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			parts = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading {role} failed!\nData:{_save.unique_data}\nError:{arg}");
			parts = new List<int>();
		}
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		List<int> list = (from _r in _snap.address_occupents
			where _r.Value.getVisualAlignment() == Alignments.EVIL
			select _r.Key).ToList();
		List<int> list2 = list.Where((int _a) => _a > base.address).ToList();
		if (!base.has_bad_info)
		{
			parts = list2;
			return checkTranslationWithPlural(getInfoEnglish, list2.Count);
		}
		int num = random.Next(0, list.Count + 1);
		if (num == list2.Count)
		{
			num = (num + 1) % (list.Count + 1);
		}
		return checkTranslationWithPlural(getInfoEnglish, num);
	}

	private string getInfoEnglish(string _data)
	{
		return "I've spotted " + _data + " evil role{#/s}.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() > base.address;
		}
		return false;
	}

	public override bool checkEndInfoHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return parts.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return parts.toStringCommaSeperated();
	}
}
