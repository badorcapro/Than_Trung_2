using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Broker : RoleData
{
	public override Roles role => Roles.BROKER;

	public override string english_name => "Broker";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " how many " + TextHelper.evilRoles + " are " + Keywords.SURROUNDING.toString() + " the " + LocationTypes.CRIME_SCENE.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounce + " a random number between 0 and 4 that is incorrect.") };

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public Broker(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Broker(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		Dictionary<LocationTypes, LocationData> locationsInPlay = _snap.board.getLocationsInPlay();
		if (locationsInPlay.ContainsKey(LocationTypes.BLOOD_TRACE) && locationsInPlay[LocationTypes.BLOOD_TRACE].getBoardPosition().isSurroundingOrOn(_position))
		{
			return true;
		}
		return locationsInPlay[LocationTypes.CRIME_SCENE].getBoardPosition().isSurroundingOrOn(_position);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		Vector2Int boardPosition = _snap.board.getLocationsInPlay()[LocationTypes.CRIME_SCENE].getBoardPosition();
		int num = _snap.board.getSurroundingRolesFromGridPos(boardPosition, base.case_ref.board_size).Aggregate(0, (int _a, RoleData _r) => _a + ((_r.getVisualAlignment() == Alignments.EVIL) ? 1 : 0));
		if (base.has_bad_info)
		{
			int num2 = random.Next(0, 5);
			if (num2 == num)
			{
				num2 = (num2 + 1) % 5;
			}
			return getInfoStringWithData(num2);
		}
		return getInfoStringWithData(num);
	}

	private string getInfoStringWithData(int _adjacent_evil)
	{
		return LocalisationHelper.checkPlural(checkTranslationWithData(getInfoEnglish, _adjacent_evil), _adjacent_evil);
	}

	private string getInfoEnglish(string _data)
	{
		return "There {#is/are} " + _data + " evil role{#/s} close to the Crime Scene.";
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
