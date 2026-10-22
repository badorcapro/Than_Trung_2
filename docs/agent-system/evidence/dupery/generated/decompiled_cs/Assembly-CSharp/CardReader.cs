using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class CardReader : CasinoRoleData
{
	public override Roles role => Roles.CARD_READER;

	public override string english_name => "Card Reader";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " if at least 1 " + TextHelper.evilRole + " is at an " + Keywords.ADDRESS.toString() + " equal to one of your " + TextHelper.cardsValue + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, TextHelper.faceCards_cap + " have no " + TextHelper.value + " and point to no " + TextHelper.addresses + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounceOppositeOfTrue));
			return list;
		}
	}

	public override string credits => "Devy L. & D. Espair";

	public override bool hasInfo => true;

	public override bool has_hover_focus => false;

	private string loc_evil_info_key => $"{role} [info_evil]";

	public CardReader(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public CardReader(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override string generateCasinoInfoString(CasinoCaseSnapshot _snap)
	{
		List<int> list = new List<int>();
		if (_snap.casino_payload.left_card.value <= 10)
		{
			list.Add(_snap.casino_payload.left_card.value);
		}
		if (_snap.casino_payload.right_card.value <= 10)
		{
			list.Add(_snap.casino_payload.right_card.value);
		}
		Dictionary<int, RoleData> occupents = _snap.address_occupents;
		bool flag = list.Any((int _a) => occupents.ContainsKey(_a) && occupents[_a].getVisualAlignment() == Alignments.EVIL);
		if (base.has_bad_info)
		{
			flag = !flag;
		}
		if (flag)
		{
			return checkTranslation(loc_evil_info_key, getEvilInfoEnglish);
		}
		return checkTranslation(getGoodInfoEnglish);
	}

	private string getGoodInfoEnglish()
	{
		return "Your cards show no evil.";
	}

	private string getEvilInfoEnglish()
	{
		return "Evil lurks within your cards!";
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
