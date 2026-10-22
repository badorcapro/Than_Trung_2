using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Valet : CasinoRoleData, IHaveSpecialAbility, IHaveAbility
{
	private const int royalty_card = 20;

	private Maybe<CasinoCard> card_picked = new Maybe<CasinoCard>();

	public override Roles role => Roles.VALET;

	public override string english_name => "Valet";

	public override string english_description => $"{Keywords.ABILITY.toStringCap()}: Pick a {Keywords.CARD.toString()} and discard it. If the {Keywords.CARD.toString()} picked is a {Keywords.FACE_CARD.toString()}, gain {20} {TextHelper.chips_with_link}. Otherwise " + "I " + Keywords.ANNOUNCE.toString() + " the identity of the " + Keywords.ROLE.toString() + " that lives at the " + TextHelper.cardsValue + " " + Keywords.ADDRESS.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "If no " + TextHelper.roles + " live at the " + Keywords.ADDRESS.toString() + " of the chosen " + TextHelper.cardsValue + ", I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\"."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", if you picked a " + Keywords.FACE_CARD.toString() + ", I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\". Otherwise I " + Keywords.ANNOUNCE.toString() + " a random " + TextHelper.suspectedRole + " that is incorrect."));
			return list;
		}
	}

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

	public SpecialAbilityType ability_type => SpecialAbilityType.CARD_ABILITY;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	private string loc_info_empty_key => $"{role} [info_empty]";

	private string loc_info_full_key => $"{role} [info_full]";

	private string loc_info_lie_key => $"{role} [info_lie]";

	public Valet(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Valet(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		if (_save.unique_data != "")
		{
			try
			{
				card_picked = CasinoCard.parse(_save.unique_data).maybe();
			}
			catch (Exception arg)
			{
				Debug.LogError($"Could not parse the save data ({role} | '{_save.unique_data}')!\nError: {arg}");
				card_picked = new Maybe<CasinoCard>();
			}
		}
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		return _type switch
		{
			DescriptionType.SPECIAL => _description.Replace(RoleData.loc_marker_1, checkTranslationWithData(loc_info_empty_key, noOccupentInfoEnglish, "")), 
			DescriptionType.LYING_OR_TAINTED => _description.Replace(RoleData.loc_marker_1, checkTranslation(loc_info_lie_key, gainChipsLying)), 
			_ => _description, 
		};
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address != base.address)
		{
			return;
		}
		if (_data.Count > 0 && _data[0] is CasinoCardAbilityData casinoCardAbilityData)
		{
			card_picked = casinoCardAbilityData.card_picked.maybe();
			base.casino_case.replaceCard(casinoCardAbilityData.card_picked);
			if (casinoCardAbilityData.card_picked.value >= 11 && !base.has_bad_info)
			{
				base.casino_case.gainChips(20);
			}
		}
		else
		{
			Debug.LogError($"Did not know how to parse special ability data! List was either empty or of the wrong type! ({role})");
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
			Debug.LogError($"{role} | Trying to get info string before card is picked!");
			return "";
		}
		if (card_picked.value.value >= 11)
		{
			if (base.has_bad_info)
			{
				return checkTranslation(loc_info_lie_key, gainChipsLying);
			}
			return checkTranslationWithData(gainChipsInfoEnglish, 20);
		}
		Dictionary<int, RoleData> address_occupents = _snap.address_occupents;
		if (base.has_bad_info)
		{
			RoleData rng_suspect = _snap.true_suspect_list.getRandomElement(random);
			if (address_occupents.ContainsKey(card_picked.value.value) && rng_suspect.role == address_occupents[card_picked.value.value].role)
			{
				rng_suspect = _snap.true_suspect_list.Where((RoleData _r) => _r.role != rng_suspect.role).ToList().getRandomElementFromList(random);
			}
			return checkTranslationWithReplace(loc_info_full_key, () => occupentInfoEnglish(rng_suspect.name, card_picked.value.value.ToString()), () => rng_suspect.name, ((object)card_picked.value.value).ToString);
		}
		if (!address_occupents.ContainsKey(card_picked.value.value))
		{
			return checkTranslationWithData(loc_info_empty_key, noOccupentInfoEnglish, card_picked.value.value);
		}
		string role_name = address_occupents[card_picked.value.value].name;
		return checkTranslationWithReplace(loc_info_full_key, () => occupentInfoEnglish(role_name, card_picked.value.value.ToString()), () => role_name, ((object)card_picked.value.value).ToString);
	}

	private string gainChipsInfoEnglish(string _data)
	{
		return "Here are your " + _data + " chips.";
	}

	private string gainChipsLying()
	{
		return "I am sorry. I cannot give you any chips.";
	}

	private string noOccupentInfoEnglish(string _data)
	{
		return "No one lives at #" + _data;
	}

	private string occupentInfoEnglish(string _data, string _data_2)
	{
		return "The " + _data + " lives at #" + _data_2 + ".";
	}

	public override string getTruthString()
	{
		return (card_picked.is_some ? (checkTranslationWithReplace(base.loc_default_truth_key, englishTruth, () => card_picked.value.info.valueString(), () => card_picked.value.info.suitTextSprite()) + "\n") : "") + base.getTruthString();
	}

	private string englishTruth()
	{
		return englishTruth(card_picked.value.info.valueString(), card_picked.value.info.suitTextSprite());
	}

	private string englishTruth(string _data, string _data_2)
	{
		return "You picked the " + _data + " of " + _data_2 + ".";
	}

	public override string getUniqueSaveData()
	{
		if (!card_picked.is_some)
		{
			return "";
		}
		return CasinoCard.toData(card_picked.value);
	}
}
