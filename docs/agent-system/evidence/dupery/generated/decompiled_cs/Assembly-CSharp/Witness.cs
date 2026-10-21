using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Witness : RoleData
{
	public override Roles role => Roles.WITNESS;

	public override string english_name => "Witness";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " how many " + Keywords.STEPS.toString() + " I would need to take to reach the " + LocationTypes.CRIME_SCENE.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, TextHelper.iAmSelfConfirm));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a random number of " + Keywords.STEPS.toString() + " between 1 and 4 that is incorrect."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public Witness(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Witness(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(default(RoleGenerationMarkers));
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		Vector2Int boardPosition = _snap.board.getLocationsInPlay()[LocationTypes.CRIME_SCENE].getBoardPosition();
		int num = Mathf.Abs(boardPosition.x - base.board_position.x) + Mathf.Abs(boardPosition.y - base.board_position.y);
		if (!base.has_bad_info)
		{
			return checkTranslationWithPlural(getInfoEnglish, num);
		}
		int num2 = random.Next(1, 5);
		if (num2 == num)
		{
			num2++;
		}
		return checkTranslationWithPlural(getInfoEnglish, num2);
	}

	private string getInfoEnglish(string _data)
	{
		return "The Crime Scene is " + _data + " step{#/s} away...";
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
