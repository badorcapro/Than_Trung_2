using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class TabbyCat_dep : RoleData
{
	public int tabby_num = -1;

	public override Roles role => Roles.S_TABBY_CAT;

	public override string english_name => "Tabby Cat";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " the " + Keywords.ADDRESS.toString() + " of an " + RoleClassifications.INNOCENT.toString() + " or " + RoleClassifications.MEDDLER.toString() + " " + Keywords.ROLE.toString() + " that has become " + Alignments.EVIL.toString() + ". If all " + RoleClassifications.INNOCENT.toString() + " and " + TextHelper.meddlerRoles + " are " + Alignments.GOOD.toString() + ", I meow instead.";

	public override bool hasInfo => true;

	private string loc_hiss_info_key => $"{role} [hiss]";

	private string loc_meow_info_key => $"{role} [meow]";

	public TabbyCat_dep(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		tabby_num = int.Parse(_save.unique_data);
	}

	public TabbyCat_dep(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		List<RoleData> list = _snap.address_occupents.Values.Where((RoleData _e) => _e.getVisualAlignment() == Alignments.EVIL && (_e.getVisualClassification() == RoleClassifications.INNOCENT || _e.getVisualClassification() == RoleClassifications.MEDDLER)).ToList();
		if (list.Count == 0)
		{
			tabby_num = 0;
		}
		else
		{
			tabby_num = list.Select((RoleData _e) => _e.getAddress()).ToList().getRandomElementFromList(random);
		}
		if (base.has_bad_info)
		{
			List<RoleData> list2 = _snap.address_occupents.Values.Where((RoleData _e) => _e.getVisualAlignment() == Alignments.GOOD && (_e.getVisualClassification() == RoleClassifications.INNOCENT || _e.getVisualClassification() == RoleClassifications.MEDDLER)).ToList();
			if (list2.Count == 0)
			{
				return checkTranslation(loc_hiss_info_key, getHissEnglish);
			}
			tabby_num = list2.Select((RoleData _e) => _e.getAddress()).ToList().getRandomElementFromList(random);
		}
		if (tabby_num != 0)
		{
			return checkTranslationWithReplace(() => getInfoEnglish(tabby_num), tabby_num);
		}
		return checkTranslation(loc_meow_info_key, getMeowEnglish);
	}

	private string getInfoEnglish(int _data)
	{
		return getInfoEnglish(_data.ToString());
	}

	private string getInfoEnglish(string _data)
	{
		return "*Wanders towards #" + _data + "*";
	}

	private string getHissEnglish()
	{
		return "*Hiss!*";
	}

	private string getMeowEnglish()
	{
		return "Meow!";
	}

	public override string getUniqueSaveData()
	{
		return tabby_num.ToString();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}
}
