using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class HotShot : CasinoRoleData, IHaveSpecialAbility, IHaveAbility
{
	private const int ability_multi = 5;

	private int chips;

	public override Roles role => Roles.HOT_SHOT;

	public override string english_name => "Hot Shot";

	public override string english_description => $"{Keywords.ABILITY.toStringCap()}: Pick a {Keywords.CARD.toString()} and discard it. Gain {5}x its {Keywords.CARD_VALUE.toString()} in {TextHelper.chips_with_link}. " + $"If I am {TextHelper.lyingOrTainted}, lose {5}x it's {Keywords.CARD_VALUE.toString()} in {TextHelper.chips_with_link} instead.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I consider Jack, Queen and King " + TextHelper.cards + " as having a " + Keywords.CARD_VALUE.toString() + " of 10."));
			list.Add((DescriptionType.LYING_OR_TAINTED, "I truthfully " + Keywords.ANNOUNCE.toString() + " how many " + TextHelper.chips_with_link + " you won or lost even when I am " + TextHelper.lyingOrTainted + "."));
			return list;
		}
	}

	public override string credits => "Smile";

	public override bool hasInfo => abilityExhausted;

	public SpecialAbilityType ability_type => SpecialAbilityType.CARD_ABILITY;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	private string loc_info_lost_key => $"{role} [info_l]";

	public HotShot(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public HotShot(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.SELF_CONFIRM, RoleGenerationMarkers.HAS_ABILITY);
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address != base.address)
		{
			return;
		}
		if (_data.Count > 0 && _data[0] is CasinoCardAbilityData casinoCardAbilityData)
		{
			int num = Mathf.Min(casinoCardAbilityData.card_picked.value, 10);
			base.casino_case.replaceCard(casinoCardAbilityData.card_picked);
			chips = num * 5;
			if (base.has_bad_info)
			{
				base.casino_case.spendChips(chips);
			}
			else
			{
				base.casino_case.gainChips(chips);
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

	protected override string generateCasinoInfoString(CasinoCaseSnapshot _snap)
	{
		if (base.has_bad_info)
		{
			return checkTranslationWithData(loc_info_lost_key, englishInfoLost, chips);
		}
		return checkTranslationWithData(englishInfoWon, chips);
	}

	private string englishInfoWon(string _data)
	{
		return "*You gained " + _data + " chips!*";
	}

	private string englishInfoLost(string _data)
	{
		return "*You lost " + _data + " chips!*";
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
