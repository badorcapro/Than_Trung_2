using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Receptionist : CasinoRoleData, IHaveSpecialAbility, IHaveAbility
{
	private const int ability_cost = 2;

	private Maybe<Roles> suspect_picked = new Maybe<Roles>();

	public override Roles role => Roles.RECEPTIONIST;

	public override string english_name => "Receptionist";

	public override string english_description => TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.ROLE.toString() + " from the " + Keywords.SUSPECT_LIST.toString() + ". I " + Keywords.ANNOUNCE.toString() + " if they are " + Keywords.IN_PLAY.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounceOppositeOfTrue) };

	public override string credits => "Rsvdark";

	public override bool hasInfo
	{
		get
		{
			if (ability_exhausted)
			{
				return suspect_picked.is_some;
			}
			return false;
		}
	}

	public SpecialAbilityType ability_type => SpecialAbilityType.SUSPECT;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public override bool has_end_info_hover_focus => suspect_picked.is_some;

	private string loc_info_nip_key => $"{role} [info_nip]";

	public Receptionist(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Receptionist(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		if (_save.unique_data != "")
		{
			try
			{
				suspect_picked = ((Roles)int.Parse(_save.unique_data)).maybe();
			}
			catch (Exception arg)
			{
				Debug.LogError($"Could not parse the save data ({role} | '{_save.unique_data}')!\nError: {arg}");
				suspect_picked = new Maybe<Roles>();
			}
		}
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, Mathf.FloorToInt(2f * (_snapshot as CasinoCaseSnapshot).casino_payload.cost_multi).ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 2.ToString());
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address == base.address)
		{
			base.casino_case.spendChips(2);
			if (_data.Count > 0 && _data[0] is SuspectAbilityData suspectAbilityData)
			{
				suspect_picked = suspectAbilityData.role.maybe();
			}
			else
			{
				Debug.LogError($"Did not know how to parse special ability data! List was either empty or of the wrong type! ({role})");
			}
		}
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectASuspectLocalised;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (!suspect_picked.is_some)
		{
			Debug.LogError($"{role} | Trying to get info string before suspect is picked!");
			return "";
		}
		bool flag = _snap.address_occupents.Values.Any((RoleData _r) => _r.role == suspect_picked.value);
		if (base.has_bad_info)
		{
			flag = !flag;
		}
		if (flag)
		{
			return checkTranslationWithData(inTownEnglish, suspect_picked.value.toString());
		}
		return checkTranslationWithData(loc_info_nip_key, notInTownEnglish, suspect_picked.value.toString());
	}

	private string inTownEnglish(string _data)
	{
		return "The " + _data + " is in the Casino.";
	}

	private string notInTownEnglish(string _data)
	{
		return "The " + _data + " is not around today.";
	}

	public override bool checkEndInfoHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.role == suspect_picked.value;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		if (!suspect_picked.is_some)
		{
			return "";
		}
		return ((int)suspect_picked.value).ToString();
	}
}
