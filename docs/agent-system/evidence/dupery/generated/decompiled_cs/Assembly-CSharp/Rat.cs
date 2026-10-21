using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Rat : RoleData
{
	private Maybe<Roles> victim = new Maybe<Roles>();

	public override Roles role => Roles.RAT;

	public override string english_name => "Rat";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " \"Squeak Squeak\".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.SPECIAL, TextHelper.iCannotNaturallyBeInPlay) };

	public override bool hasInfo => true;

	public override bool can_be_disguise => false;

	public Rat(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Rat(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		if (_save.unique_data == null || _save.unique_data == "")
		{
			victim = new Maybe<Roles>();
		}
		else
		{
			victim = ((Roles)int.Parse(_save.unique_data)).maybe();
		}
	}

	public void setVictim(RoleData _data)
	{
		victim = _data.role.maybe();
	}

	public override string getTruthString()
	{
		return (victim.is_some ? (checkTranslationWithData(base.loc_default_truth_key, getTruthEnglish, victim.value.toStringPlain()) + "\n") : "") + checkTranslation(getInfoEnglish);
	}

	private string getTruthEnglish(string _data)
	{
		return "I used to be the " + _data + ".";
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return checkTranslation(getInfoEnglish);
	}

	private string getInfoEnglish()
	{
		return "Squeak Squeak";
	}

	public override string getUniqueSaveData()
	{
		if (!victim.is_some)
		{
			return "";
		}
		return ((int)victim.value).ToString();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.MEDDLER;
	}
}
