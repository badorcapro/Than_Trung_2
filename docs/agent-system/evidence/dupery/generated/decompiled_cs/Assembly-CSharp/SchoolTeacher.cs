using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class SchoolTeacher : RoleData
{
	public override Roles role => Roles.TEACHER;

	public override string english_name => "Teacher";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " how many " + TextHelper.evilRoles + " are in adjacent columns.";

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public SchoolTeacher(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public SchoolTeacher(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return Mathf.Abs(base.board_position.x - _position.x) == 1;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		int announce = getEvilInAdjacent(_snap);
		return checkTranslationWithReplace(() => getInfoEnglish(announce), announce);
	}

	private string getInfoEnglish(int _data)
	{
		return getInfoEnglish(_data.ToString());
	}

	private string getInfoEnglish(string _data)
	{
		return "I have " + _data + " students";
	}

	private int getEvilInAdjacent(CaseSnapshot _snap)
	{
		int num = 0;
		int num2 = 0;
		foreach (KeyValuePair<Vector2Int, Maybe<Either<RoleData, LocationData>>> item in _snap.board)
		{
			if (item.Value.is_some && item.Value.value.is_a && Mathf.Abs(base.board_position.x - item.Key.x) == 1)
			{
				num2++;
				if (item.Value.value.maybe_a.value.getVisualAlignment() == Alignments.EVIL)
				{
					num++;
				}
			}
		}
		if (base.has_bad_info)
		{
			if (num2 == 0)
			{
				return random.Next(1, 4);
			}
			if (num == 0)
			{
				return random.Next(1, num2);
			}
			return (num + random.Next(1, num2)) % num2;
		}
		return num;
	}

	public override string getUniqueSaveData()
	{
		return "";
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
