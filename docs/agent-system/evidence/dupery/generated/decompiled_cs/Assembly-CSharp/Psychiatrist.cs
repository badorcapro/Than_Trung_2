using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Psychiatrist : RoleData
{
	public override Roles role => Roles.PSYCHIATRIST;

	public override string english_name => "Psychiatrist";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " how many " + Keywords.S_NEIGHBOURS.toString() + " are " + TextHelper.lyingOrTainted + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a number between 0 and 4 that is incorrect.") };

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public Psychiatrist(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Psychiatrist(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return base.board_position.getNeighboursFromPositionWithinGrid(base.case_ref.board_size).Contains(_position);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		List<RoleData> surroundingRolesFromGridPos = _snap.board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size);
		int count = surroundingRolesFromGridPos.Where((RoleData _r) => _r.getIsLying() || _r.getIsTainted()).ToList().Count;
		if (base.has_bad_info)
		{
			int num = random.Next(0, Mathf.Max(4, surroundingRolesFromGridPos.Count + 1));
			if (num == count)
			{
				num = num % 4 + 1;
			}
			return getInfo(num);
		}
		return getInfo(count);
	}

	private string getInfo(int _number)
	{
		return checkTranslationWithPlural(getInfoEnglish, _number);
	}

	private string getInfoEnglish(string _data)
	{
		return "I have " + _data + " untrustworthy neighbour{#/s}.";
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
