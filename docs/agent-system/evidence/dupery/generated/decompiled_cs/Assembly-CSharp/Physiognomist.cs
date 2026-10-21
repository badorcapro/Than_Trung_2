using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Physiognomist : RoleData
{
	private List<int> parts = new List<int>();

	public override Roles role => Roles.PHYSIOGNOMIST;

	public override string english_name => "Physiognomist";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " how many " + TextHelper.innocentRoles + " are " + TextHelper.tainted + " specifying how many are " + TextHelper.investigated + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I will " + Keywords.ANNOUNCE.toString() + " that a random incorrect number of " + TextHelper.innocentRoles + " are " + TextHelper.tainted + ", and that a random number of them are " + TextHelper.investigated + ". The second part of my statement can be true."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_end_info_hover_focus => parts.Count > 0;

	private string loc_no_taint_key => $"{role} [info_nt]";

	public Physiognomist(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Physiognomist(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		parts = RoleHelper.tryLoadListFromUniqueData(role, _save);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		List<RoleData> list = (from _r in _snap.board.getRolesInPlayOfClass(default(RoleClassifications))
			where _r.getIsTainted()
			select _r).ToList();
		int count = list.Count;
		int inv = list.Count((RoleData _r) => _r.getIsInvestigated());
		if (base.has_bad_info)
		{
			int num = random.Next(1, 3);
			int num2 = ((num > count || random.Next(0, 2) == 1) ? (count + num) : (count - num));
			if (num2 == 0)
			{
				return checkTranslation(loc_no_taint_key, infoNoTaintEnglish);
			}
			int num3 = _snap.address_occupents.Values.Count((RoleData _r) => _r.getIsInvestigated());
			int inv2 = ((num3 != 0) ? random.Next(0, Mathf.Min(num3, num2)) : 0);
			return getInfo(num2, inv2);
		}
		parts = list.Select((RoleData _r) => _r.getAddress()).ToList();
		if (count == 0)
		{
			return checkTranslation(loc_no_taint_key, infoNoTaintEnglish);
		}
		return getInfo(count, inv);
	}

	private string getInfo(int _total, int _inv)
	{
		return LocalisationHelper.checkPlural(checkTranslationWithReplace(() => infoEnglish(_total.ToString(), _inv.ToString()), _total, _inv), _total);
	}

	private string infoEnglish(string _d1, string _d2)
	{
		return _d1 + " role{#/s} {#is/are} tainted. You've spoken to " + _d2 + " of them.";
	}

	private string infoNoTaintEnglish()
	{
		return "No one is tainted.";
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
