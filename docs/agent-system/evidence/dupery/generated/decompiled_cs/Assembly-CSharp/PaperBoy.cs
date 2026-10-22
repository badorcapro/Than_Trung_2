using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class PaperBoy : RoleData
{
	public override Roles role => Roles.PAPER_BOY;

	public override string english_name => "Paper Boy";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " how many " + TextHelper.evilRoles + " have at least 1 " + Alignments.EVIL.toString() + " " + Keywords.CA_NEIGHBOURS.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a random number between 0 and the number of " + Keywords.IN_PLAY.toString() + " " + TextHelper.evilRoles + " that is incorrect."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public PaperBoy(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public PaperBoy(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new ClassificationRatioGC(RoleClassifications.UNDERLING, 2, DisguiseConstraintType.NEVER_IGNORE));
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		List<Vector2Int> list = (from _r in _snap.address_occupents
			where _r.Value.getVisualAlignment() == Alignments.EVIL
			select _r.Value.getBoardPosition()).ToList();
		HashSet<int> hashSet = new HashSet<int>();
		for (int i = 0; i < list.Count - 1; i++)
		{
			for (int j = i + 1; j < list.Count; j++)
			{
				if (list[i].isAdjacent(list[j]))
				{
					hashSet.Add(i);
					hashSet.Add(j);
				}
			}
		}
		int count = hashSet.Count;
		if (!base.has_bad_info)
		{
			return checkTranslationWithPlural(getInfoEnglish, count);
		}
		if (list.Count < 2)
		{
			return checkTranslationWithPlural(getInfoEnglish, 1);
		}
		int num = random.Next(0, list.Count);
		if (num >= 1 && list.Count >= 2)
		{
			num++;
		}
		if (num == count)
		{
			num = (num + 1) % (list.Count + 1);
		}
		return checkTranslationWithPlural(getInfoEnglish, num);
	}

	private string getInfoEnglish(string _data)
	{
		return "There {#is/are} " + _data + " neighbouring evil role{#/s}.";
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
