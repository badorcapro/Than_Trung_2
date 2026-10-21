using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Iconographer : RoleData
{
	private List<int> parts = new List<int>();

	public override Roles role => Roles.ICONOGRAPHER;

	public override string english_name => "Iconographer";

	public override string english_description => TextHelper.whenInvestigatedIAnnounce + " the sum of all non-" + TextHelper.innocentRole + " " + TextHelper.addresses + " that are closer to the " + LocationTypes.CRIME_SCENE.toString() + " than I am.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I sum the " + TextHelper.addresses + " of non-" + TextHelper.innocentRoles + " whose number of " + Keywords.STEPS.toString() + " to the " + LocationTypes.CRIME_SCENE.toString() + " is strictly smaller than my own."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.ANNOUNCE.toString() + " a sum that is either higher or lower than the true sum."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public override bool has_end_info_hover_focus => parts.Count > 0;

	public Iconographer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Iconographer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			parts = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading {role} failed!\nData:{_save.unique_data}\nError:{arg}");
			parts = new List<int>();
		}
	}

	protected override bool getEnglishNamePrefixOption()
	{
		return false;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		Dictionary<LocationTypes, LocationData> locationsInPlay = _snap.board.getLocationsInPlay();
		if (!locationsInPlay.ContainsKey(LocationTypes.CRIME_SCENE))
		{
			Debug.LogError($"{role} | Could not find crime scene!?");
			return "";
		}
		Vector2Int crime_scene_pos = locationsInPlay[LocationTypes.CRIME_SCENE].getBoardPosition();
		int my_dist = crime_scene_pos.cardinalDistance(base.board_position);
		List<RoleData> rolesInPlayOfClass = _snap.board.getRolesInPlayOfClass(RoleClassifications.UNDERLING, RoleClassifications.MEDDLER, RoleClassifications.TRAITOR);
		parts = rolesInPlayOfClass.whereSelect((RoleData _i) => crime_scene_pos.cardinalDistance(_i.getBoardPosition()) < my_dist, (RoleData _i) => _i.getAddress());
		int num = parts.Sum();
		if (base.has_bad_info)
		{
			int num2 = 0;
			int num3 = random.Next(1, 6);
			num2 = ((num >= num3 && random.Next(0, 2) != 1) ? (num - num3) : (num + num3));
			return getInfo(num2);
		}
		return getInfo(num);
	}

	private string getInfo(int _nb)
	{
		return LocalisationHelper.checkPlural(checkTranslationWithData(getInfoEnglish, _nb), _nb);
	}

	private string getInfoEnglish(string _data)
	{
		return "I've made " + _data + " icon{#/s}";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		Dictionary<LocationTypes, LocationData> locationsInPlay = _snap.board.getLocationsInPlay();
		if (!locationsInPlay.ContainsKey(LocationTypes.CRIME_SCENE))
		{
			return false;
		}
		Vector2Int boardPosition = locationsInPlay[LocationTypes.CRIME_SCENE].getBoardPosition();
		return _position.cardinalDistance(boardPosition) < base.board_position.cardinalDistance(boardPosition);
	}

	public override bool checkEndInfoHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return parts.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return parts.toStringCommaSeperated();
	}
}
