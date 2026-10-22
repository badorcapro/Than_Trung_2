using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Tipster : RoleData
{
	public override Roles role => Roles.TIPSTER;

	public override string english_name => "Tipster";

	public override string english_description => TextHelper.whenInvestigated + ", I " + Keywords.ANNOUNCE.toString() + " how many " + TextHelper.evilRoles + " are " + Keywords.UNINVESTIGATED.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.ANNOUNCE.toString() + " a random number of " + TextHelper.evilRoles + " that is incorrect."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public Tipster(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Tipster(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		Dictionary<int, RoleData> address_occupents = _snap.address_occupents;
		List<RoleData> list = address_occupents.Values.Where((RoleData _r) => !_r.getIsInvestigated()).ToList();
		int num = list.Count((RoleData _r) => _r.getVisualAlignment() == Alignments.EVIL);
		if (base.has_bad_info)
		{
			int b = address_occupents.Values.Count((RoleData _r) => _r.getVisualAlignment() == Alignments.EVIL);
			int num2 = Mathf.Min(list.Count, b);
			if (num2 == 0)
			{
				num2 = Mathf.Max(1, b);
			}
			int num3 = random.Next(0, num2);
			if (num3 >= num)
			{
				num3 = (num3 + 1) % (num2 + 1);
			}
			return info(num3);
		}
		return info(num);
	}

	private string info(int _data)
	{
		return checkTranslationWithData(englishEvilInfo, _data);
	}

	private string englishEvilInfo(string _data)
	{
		return "I count " + _data + " evil!";
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
