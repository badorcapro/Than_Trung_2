using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Therapist : RoleData
{
	public override Roles role => Roles.THERAPIST;

	public override string english_name => "Therapist";

	public override string english_description => TextHelper.whenInvestigated + ", I " + Keywords.ANNOUNCE.toString() + " how many of my " + TextHelper.adjacentNeighbours + " are " + Alignments.EVIL.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a number between 0 and 4 that is incorrect.") };

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public Therapist(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Therapist(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return base.board_position.getCardinalNeighboursFromPositionWithinGrid(base.case_ref.board_size).Contains(_position);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		int num = _snap.board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size).Where(delegate(RoleData _e)
		{
			if (!base.case_ref.hasMarkerQuirk(CaseQuirks.SHRINK))
			{
				return _e.getVisualAlignment() == Alignments.EVIL;
			}
			return _e.getVisualAlignment() == Alignments.EVIL || _e.getVisualClassification() == RoleClassifications.MEDDLER;
		}).Count();
		if (base.has_bad_info)
		{
			int num2 = random.Next(0, 5);
			if (num == num2)
			{
				num2--;
			}
			if (num2 == -1)
			{
				num2 = random.Next(1, 5);
			}
			return infoString(num2);
		}
		return infoString(num);
	}

	private string infoString(int _evil_clients)
	{
		return checkTranslationWithPlural(getInfoEnglish, _evil_clients);
	}

	private string getInfoEnglish(int _data)
	{
		return getInfoEnglish(_data.ToString());
	}

	private string getInfoEnglish(string _data)
	{
		return "I have " + _data + " evil client{#/s}.";
	}

	public RoleData createAndForceSetInfo(int _evil_clients)
	{
		base.info_string = infoString(_evil_clients).maybe();
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
		return "";
	}
}
