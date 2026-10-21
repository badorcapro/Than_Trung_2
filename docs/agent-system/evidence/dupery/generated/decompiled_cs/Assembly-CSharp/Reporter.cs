using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Reporter : RoleData
{
	private int steps_said = -1;

	public override Roles role => Roles.REPORTER;

	public override string english_name => "Reporter";

	public override string english_description => TextHelper.whenInvestigated + ", I " + Keywords.ANNOUNCE.toString() + " how many " + Keywords.STEPS.toString() + " I'd need to take to reach the closest " + TextHelper.evilRole + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I cannot report myself."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a random number of " + Keywords.STEPS.toString() + " between 1 and 4 that is incorrect."));
			return list;
		}
	}

	public override bool has_hover_focus => true;

	public override bool has_end_info_hover_focus => true;

	public override bool hasInfo => true;

	private string loc_no_info_key => $"{role} [no_info]";

	public Reporter(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Reporter(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		steps_said = int.Parse(_save.unique_data);
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _position.cardinalDistance(base.board_position) == steps_said;
		}
		return false;
	}

	public override bool checkEndInfoHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (checkHoverFocus(_snap, _position, _occupent))
		{
			if (!base.has_bad_info)
			{
				return _occupent.maybe_a.value.getVisualAlignment() == Alignments.EVIL;
			}
			return true;
		}
		return false;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		Maybe<RoleData> closestEvilAlignedFromCurrentPos = _snap.board.getClosestEvilAlignedFromCurrentPos(base.board_position);
		int num = -1;
		if (closestEvilAlignedFromCurrentPos.is_some)
		{
			Vector2Int vector2Int = closestEvilAlignedFromCurrentPos.value.getBoardPosition() - base.board_position;
			num = Mathf.Abs(vector2Int.x) + Mathf.Abs(vector2Int.y);
		}
		if (base.has_bad_info)
		{
			int num2 = random.Next(1, 4);
			if (num2 == num)
			{
				num2++;
			}
			steps_said = num2;
			return infoString(num2);
		}
		steps_said = num;
		return infoString(num);
	}

	private string infoString(int _steps)
	{
		if (_steps != -1)
		{
			return checkTranslationWithPlural(getInfoEnglish, _steps);
		}
		return checkTranslation(loc_no_info_key, getNoInfoEnglish);
	}

	private string getInfoEnglish(int _data)
	{
		return getInfoEnglish(_data.ToString());
	}

	private string getInfoEnglish(string _data)
	{
		return "I'm " + _data + " step{#/s} away from closest evil!";
	}

	private string getNoInfoEnglish()
	{
		return "I did not find any evil.";
	}

	public RoleData createAndForceSetInfo(int _steps)
	{
		base.info_string = infoString(_steps).maybe();
		steps_said = _steps;
		return this;
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
		return steps_said.ToString();
	}
}
