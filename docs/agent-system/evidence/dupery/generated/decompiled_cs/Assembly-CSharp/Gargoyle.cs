using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Gargoyle : ClockRoleData
{
	[Serializable]
	private struct GargoyleSaveInfo
	{
		public bool no_roles_left;

		public List<Roles> roles_mentioned;

		public bool has_announcement
		{
			get
			{
				if (!no_roles_left)
				{
					return roles_mentioned.Count > 0;
				}
				return true;
			}
		}

		public string latest => roles_mentioned.last().toStringPlain();

		public void mentionNewRole(Roles _role)
		{
			roles_mentioned.Add(_role);
		}

		public GargoyleSaveInfo(bool _nrl, List<Roles> _mentioned)
		{
			no_roles_left = _nrl;
			roles_mentioned = _mentioned;
		}
	}

	private GargoyleSaveInfo gargoyle_save;

	public override Roles role => Roles.GARGOYLE;

	public override string english_name => "Gargoyle";

	public override string english_description => "If I am " + TextHelper.investigated + " when the " + LocationTypes.CLOCK_TOWER.toString() + " rings I " + Keywords.ANNOUNCE.toString() + " an " + Keywords.IN_PLAY.toString() + " " + TextHelper.evilRole + " if possible.\nI make the " + LocationTypes.CLOCK_TOWER.toString() + " ring 4 hours after I am " + TextHelper.investigated + ".\nI add a " + LocationTypes.CLOCK_TOWER.toString() + " on the " + Keywords.BOARD.toString() + " when I am " + Keywords.SUSPECTED.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I make the " + LocationTypes.CLOCK_TOWER.toString() + " ring even if I am " + TextHelper.lyingOrTainted + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a " + Keywords.NOT_IN_PLAY.toString() + " " + TextHelper.evilRole + " if possible instead."));
			return list;
		}
	}

	public override bool hasInfo => gargoyle_save.has_announcement;

	public override bool has_hover_focus => true;

	private string loc_info_no_role => $"{role} [no_role]";

	public Gargoyle(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
		gargoyle_save = new GargoyleSaveInfo(_nrl: false, new List<Roles>());
	}

	public Gargoyle(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			gargoyle_save = JsonUtility.FromJson<GargoyleSaveInfo>(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\n{_save.unique_data}\nError: {arg}");
			gargoyle_save = new GargoyleSaveInfo(_nrl: false, new List<Roles>());
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new SuspectLocationGC(LocationTypes.CLOCK_TOWER));
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_b)
		{
			return _occupent.maybe_b.value.location_type == LocationTypes.CLOCK_TOWER;
		}
		return false;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (_investigated_address == base.address)
		{
			Dictionary<LocationTypes, LocationData> locationsInPlay = _board.getLocationsInPlay();
			if (!locationsInPlay.ContainsKey(LocationTypes.CLOCK_TOWER))
			{
				Debug.LogError($"No clocktower in a {role} game detected?");
				return _board;
			}
			(locationsInPlay[LocationTypes.CLOCK_TOWER] as ClockTower).addNewScheduledRingTime((_payload as ClockCaseActionPayload).hour_passed + 6, ClockTower.ClockTowerRingAttribution.GARGOYLE);
		}
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onLocationTriggeredAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects, LocationData _location)
	{
		if (_location.location_type != LocationTypes.CLOCK_TOWER || base.arrested || base.dead || !base.investigated)
		{
			return _board;
		}
		if (base.has_bad_info)
		{
			List<Roles> list = (from _r in (from _e in _board.getRolesNotInPlay(_suspects)
					where _e.getVisualAlignment() == Alignments.EVIL
					select _e.role).ToList()
				where !gargoyle_save.roles_mentioned.Contains(_r)
				select _r).ToList();
			if (list.Count > 0)
			{
				gargoyle_save.mentionNewRole(list.getRandomElementFromList(random));
			}
			else
			{
				gargoyle_save.no_roles_left = true;
			}
		}
		else
		{
			List<Roles> list2 = (from _r in (from _e in _board.getRolesInPlay().Values
					where _e.getVisualAlignment() == Alignments.EVIL
					select _e.role).ToList()
				where !gargoyle_save.roles_mentioned.Contains(_r)
				select _r).ToList();
			if (list2.Count > 0)
			{
				gargoyle_save.mentionNewRole(list2.getRandomElementFromList(random));
			}
			else
			{
				gargoyle_save.no_roles_left = true;
			}
		}
		resetInfo();
		return base.onLocationTriggeredAction(_board, _payload, _suspects, _location);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (!gargoyle_save.no_roles_left)
		{
			return checkTranslationWithData(getInfoStringRoleEnglish, gargoyle_save.latest);
		}
		return checkTranslation(loc_info_no_role, getInfoStringNoRolesLeftEnglish);
	}

	private string getInfoStringRoleEnglish(string _data)
	{
		return "I... See... " + _data;
	}

	private string getInfoStringNoRolesLeftEnglish()
	{
		return "I... See... None... Left...";
	}

	public override string getUniqueSaveData()
	{
		return JsonUtility.ToJson(gargoyle_save);
	}
}
