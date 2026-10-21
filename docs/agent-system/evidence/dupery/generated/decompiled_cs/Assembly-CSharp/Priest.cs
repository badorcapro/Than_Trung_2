using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Priest : RoleData
{
	public override Roles role => Roles.PRIEST;

	public override string english_name => "Priest";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " \"I am the Priest.\" When I am " + TextHelper.lying + " or " + TextHelper.tainted + ", I will " + Keywords.ANNOUNCE.toString() + " something else.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, TextHelper.iAmSelfConfirm));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " one of the following statements:" + RoleData.loc_marker_1));
			return list;
		}
	}

	public override bool hasInfo => true;

	public Priest(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Priest(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(default(RoleGenerationMarkers));
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type != DescriptionType.LYING_OR_TAINTED)
		{
			return _description;
		}
		List<string> possible_bad_english = getPossibleBadInfoEnglish();
		string text = "";
		int i;
		for (i = 0; i < possible_bad_english.Count; i++)
		{
			text += $"\n{LocalisationHelper.getQuotationMark(_start: true)}{checkTranslation(getLocBadInfoKey(i), () => possible_bad_english[i])}{LocalisationHelper.getQuotationMark(_start: false)}";
		}
		return _description.Replace(RoleData.loc_marker_1, text);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (base.has_bad_info)
		{
			List<string> possibleBadInfoEnglish = getPossibleBadInfoEnglish();
			int random_bad = random.Next(0, possibleBadInfoEnglish.Count);
			return checkTranslation(getLocBadInfoKey(random_bad), () => getPossibleBadInfoEnglish()[random_bad]);
		}
		return checkTranslation(getInfoEnglish);
	}

	private List<string> getPossibleBadInfoEnglish()
	{
		return new List<string> { "I am the prest.", "I am the monk.", "I don't feel so good...", "Am I a good priest?", "Am I a holy priest?", "Have you come to pray?", "I was the priest.", "I'll be the priest." };
	}

	private string getInfoEnglish()
	{
		return "I am the Priest.";
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

	private string getLocBadInfoKey(int _pattern)
	{
		return $"{role} [ib{_pattern}]";
	}
}
