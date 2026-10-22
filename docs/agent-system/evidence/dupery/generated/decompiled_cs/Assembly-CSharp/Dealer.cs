using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Dealer : CasinoRoleData, IHaveSpecialAbility, IHaveAbility
{
	private const int ability_cost = 2;

	private int card_value = -1;

	public override Roles role => Roles.DEALER;

	public override string english_name => "Dealer";

	public override string english_description => TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.CARD.toString() + " and discard it. I " + Keywords.ANNOUNCE.toString() + " if the majority of " + TextHelper.evilRoles + " live in " + Keywords.ADDRESS.toString() + " numbers higher or lower than the picked " + TextHelper.cardsValue + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I consider the " + TextHelper.value + " of " + TextHelper.faceCards + " to be 10."));
			list.Add((DescriptionType.SPECIAL, "If there is an equal amount of " + TextHelper.evilRoles + " in " + Keywords.ADDRESS.toString() + " numbers higher and lower than the picked " + TextHelper.cardsValue + ", I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\""));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounce + " a random incorrect statement."));
			return list;
		}
	}

	public override string credits => "wrigglys";

	public override bool hasInfo => abilityExhausted;

	public SpecialAbilityType ability_type => SpecialAbilityType.CARD_ABILITY;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	private string loc_info_higher => $"{role} [info_h]";

	private string loc_info_lower => $"{role} [info_l]";

	public Dealer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Dealer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, Mathf.FloorToInt(2f * (_snapshot as CasinoCaseSnapshot).casino_payload.cost_multi).ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 2.ToString());
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type == DescriptionType.SPECIAL)
		{
			return _description.Replace(RoleData.loc_marker_1, checkTranslation(englishInfoNeutral));
		}
		return base.fillExtraDescription(_description, _type);
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address == base.address)
		{
			if (_data.Count > 0 && _data[0] is CasinoCardAbilityData casinoCardAbilityData)
			{
				card_value = Mathf.Min(casinoCardAbilityData.card_picked.value, 10);
				base.casino_case.replaceCard(casinoCardAbilityData.card_picked);
				base.casino_case.spendChips(Mathf.FloorToInt(2f * base.casino_case.cost_multiplyer));
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

	protected override string generateCasinoInfoString(CasinoCaseSnapshot _snap)
	{
		(int, int) tuple = _snap.address_occupents.Values.Aggregate((0, 0), delegate((int, int) _a, RoleData _r)
		{
			if (_r.getVisualAlignment() != Alignments.EVIL)
			{
				return _a;
			}
			return (_r.getAddress() <= card_value) ? ((_r.getAddress() >= card_value) ? _a : (_a.Item1 + 1, _a.Item2)) : (_a.Item1, _a.Item2 + 1);
		});
		if (tuple.Item1 > tuple.Item2)
		{
			if (base.has_bad_info)
			{
				if (random.Next(0, 2) == 1)
				{
					return checkTranslation(loc_info_higher, englishHigher);
				}
				return checkTranslation(englishInfoNeutral);
			}
			return checkTranslation(loc_info_lower, englishLower);
		}
		if (tuple.Item2 > tuple.Item1)
		{
			if (base.has_bad_info)
			{
				if (random.Next(0, 2) == 1)
				{
					return checkTranslation(loc_info_lower, englishLower);
				}
				return checkTranslation(englishInfoNeutral);
			}
			return checkTranslation(loc_info_higher, englishHigher);
		}
		if (base.has_bad_info)
		{
			if (random.Next(0, 2) == 1)
			{
				return checkTranslation(loc_info_lower, englishLower);
			}
			return checkTranslation(loc_info_higher, englishHigher);
		}
		return checkTranslation(englishInfoNeutral);
	}

	private string englishInfoNeutral()
	{
		return "Time to cash out!";
	}

	private string englishHigher()
	{
		return "Evil lurks higher...";
	}

	private string englishLower()
	{
		return "Evil lurks lower...";
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
		return "";
	}
}
