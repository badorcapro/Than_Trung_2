using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class LawfulCitizen : BackAlleyRoleData
{
	private List<int> addresses = new List<int>();

	public override Roles role => Roles.LAWFUL_CITIZEN;

	public override string english_name => "Lawful Citizen";

	public override string english_description => TextHelper.whenInvestigated + ", for each " + TextHelper.lawfulItem + " in your " + TextHelper.pockets + ", I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of an " + TextHelper.innocentRole + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I can still " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of " + TextHelper.innocentRoles + ", but I will awlays " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of at least 1 none-" + TextHelper.innocentRole + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	private string loc_no_info_key => $"{role} [no_info]";

	public LawfulCitizen(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public LawfulCitizen(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			addresses = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			addresses = new List<int>();
		}
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return addresses.Contains(_occupent.maybe_a.value.getAddress());
	}

	protected override string generateBackAlleysInfoString(BackAlleysCaseSnapshot _snap)
	{
		int num = _snap.back_alleys_payload.pouch.filled_slots.Count((BackAlleySlot _s) => _s.item.value.colour == BackAlleysItemColour.LAWFUL);
		Dictionary<int, RoleData> address_occupents = _snap.address_occupents;
		List<int> innocent_addresses = (from _kvp in address_occupents
			where _kvp.Value.getVisualClassification() == RoleClassifications.INNOCENT
			select _kvp.Key).ToList();
		if (base.has_bad_info)
		{
			List<int> list = address_occupents.Keys.ToList();
			addresses.Add(list.Where((int _a) => !innocent_addresses.Contains(_a)).ToList().getRandomElementFromList(random));
			if (num > 1)
			{
				list.Remove(addresses[0]);
				addresses.AddRange(list.getRandomElementsFromList(random, Mathf.Min(num - 1, list.Count)));
			}
			addresses.Sort();
			return getInfo(addresses);
		}
		addresses = innocent_addresses.getRandomElementsFromList(random, Mathf.Min(num, innocent_addresses.Count));
		addresses.Sort();
		return getInfo(addresses);
	}

	private string getInfo(List<int> _data)
	{
		if (_data.Count != 0)
		{
			return LocalisationHelper.checkPlural(checkTranslationWithReplace(() => getInfoEnglish(CaseHelper.getSimpleMultiAddress(_data)), () => CaseHelper.getSimpleMultiAddress(_data)), _data.Count == 1);
		}
		return checkTranslation(loc_no_info_key, getNoInfoEnglish);
	}

	private string getInfoEnglish(string _data)
	{
		return _data + " {#is/are} innocent.";
	}

	private string getNoInfoEnglish()
	{
		return "I have nothing for you.";
	}

	public override string getUniqueSaveData()
	{
		return addresses.toStringCommaSeperated();
	}
}
