using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Dancer : RoleData
{
	public override Roles role => Roles.DANCER;

	public override string english_name => "Dancer";

	public override string english_description => "When the " + Roles.DJ.toString() + "'s music stops, I " + Keywords.REVEAL.toString() + " my true identity. I cannot natually be " + Keywords.IN_PLAY.toString();

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, "I will " + Keywords.REVEAL.toString() + " my true identity even when I am " + TextHelper.lyingOrTainted + "."));
			list.Add((DescriptionType.SPECIAL, TextHelper.iCannotNaturallyBeInPlay));
			return list;
		}
	}

	public override bool can_be_disguise => false;

	public override bool hasInfo => true;

	public Dancer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Dancer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.CANT_SPAWN_NATURALLY);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return checkTranslation(infoEnglish);
	}

	private string infoEnglish()
	{
		return "*Dancing*";
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.MEDDLER;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
