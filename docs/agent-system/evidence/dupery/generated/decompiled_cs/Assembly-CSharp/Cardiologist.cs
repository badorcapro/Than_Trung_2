using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Cardiologist : CasinoRoleData, IHaveSpecialAbility, IHaveAbility
{
	private const int ability_cost = 4;

	private Maybe<CasinoCard> card_picked = new Maybe<CasinoCard>();

	private List<int> targets = new List<int>();

	public override Roles role => Roles.CARDIOLOGIST;

	public override string english_name => "Card-iologist";

	public override string english_description => TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.CARD.toString() + " and discard it. I " + Keywords.ANNOUNCE.toString() + " the " + TextHelper.addresses + " of 2 " + TextHelper.roles + ", only one of which is of the " + Keywords.CLASSIFICATION.toString() + " " + TextHelper.associated + " with the " + TextHelper.suit + " of the " + Keywords.CARD.toString() + " picked.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "When I cannot find any " + TextHelper.roles + " of the " + Keywords.CLASSIFICATION.toString() + " " + TextHelper.associated + " with the " + TextHelper.suit + " of the " + Keywords.CARD.toString() + " picked, I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\"."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounce + " the " + TextHelper.addresses + " of 2 " + TextHelper.roles + " that are of an incorrect " + Keywords.CLASSIFICATION.toString() + " if possible, otherwise I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\"."));
			return list;
		}
	}

	public SpecialAbilityType ability_type => SpecialAbilityType.CARD_ABILITY;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public override bool hasInfo
	{
		get
		{
			if (ability_exhausted)
			{
				return card_picked.is_some;
			}
			return false;
		}
	}

	public override bool has_hover_focus => targets.Count > 0;

	private string loc_info_nip_key => $"{role} [info_nip]";

	public Cardiologist(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Cardiologist(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split('#');
			targets = array[0].fromStringCommaSeperate();
			if (array[1] == "f")
			{
				card_picked = new Maybe<CasinoCard>();
			}
			else
			{
				card_picked = CasinoCard.parse(array[1]).maybe();
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed {role}!\nSave: {_save.unique_data}\nError: {arg}");
			card_picked = new Maybe<CasinoCard>();
			targets = new List<int>();
		}
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, Mathf.FloorToInt(4f * (_snapshot as CasinoCaseSnapshot).casino_payload.cost_multi).ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 4.ToString());
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		return _description.Replace(RoleData.loc_marker_1, checkTranslation(loc_info_nip_key, englishNoInfo));
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address == base.address)
		{
			base.casino_case.spendChips(4);
			if (_data.Count > 0 && _data[0] is CasinoCardAbilityData casinoCardAbilityData)
			{
				card_picked = casinoCardAbilityData.card_picked.maybe();
				base.casino_case.replaceCard(casinoCardAbilityData.card_picked);
			}
			else
			{
				Debug.LogError($"Did not know how to parse special ability data! List was either empty or of the wrong type! ({role})");
			}
		}
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectACardLocalised;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (!card_picked.is_some)
		{
			Debug.LogError("Trying to get info string before card is picked!");
			return "";
		}
		RoleClassifications suit_class = card_picked.value.suit.toClass();
		(List<RoleData>, List<RoleData>) tuple = _snap.board.getRolesInPlay().Values.ToList().split((RoleData _r) => _r.getVisualClassification() == suit_class);
		if (base.has_bad_info)
		{
			if (tuple.Item2.Count < 2)
			{
				return checkTranslation(loc_info_nip_key, englishNoInfo);
			}
			List<RoleData> randomElementsFromList = tuple.Item2.getRandomElementsFromList(random, 2);
			targets = randomElementsFromList.Select((RoleData _r) => _r.getAddress()).ToList();
		}
		else
		{
			if (tuple.Item1.Count == 0)
			{
				return checkTranslation(loc_info_nip_key, englishNoInfo);
			}
			targets.Add(tuple.Item1.getRandomElementFromList(random).getAddress());
			targets.Add(tuple.Item2.getRandomElementFromList(random).getAddress());
		}
		targets.Sort();
		return checkTranslationWithReplace(() => englishInfo(targets[0].ToString(), targets[1].ToString()), () => targets[0].ToString(), () => targets[1].ToString());
	}

	private string englishInfo(string _d1, string _d2)
	{
		return "The cards chose #" + _d1 + " and #" + _d2;
	}

	private string englishNoInfo()
	{
		return "The cards were empty.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return targets.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return targets.toStringCommaSeperated() + "#" + (card_picked.is_some ? CasinoCard.toData(card_picked.value) : "f");
	}
}
