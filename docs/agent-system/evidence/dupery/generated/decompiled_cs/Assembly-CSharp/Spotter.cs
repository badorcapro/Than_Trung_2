using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Spotter : DocksRoleData, IHaveMultiAbility, IHaveSpecialAbility, IHaveAbility
{
	private class RadarLocationAbility : IHaveSpecialAbility, IHaveAbility
	{
		public SpecialAbilityType ability_type => SpecialAbilityType.LOCATION;

		public bool abilityExhausted => false;

		public int numberTargets => 1;

		public string getAbilityPrompt()
		{
			return TextHelper.ab_selectALocationLocalised;
		}

		public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
		{
		}
	}

	private class RadarSuspectAbility : IHaveSpecialAbility, IHaveAbility
	{
		public SpecialAbilityType ability_type => SpecialAbilityType.SUSPECT;

		public bool abilityExhausted => false;

		public int numberTargets => 1;

		public string getAbilityPrompt()
		{
			return TextHelper.ab_selectASuspectLocalised;
		}

		public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
		{
			throw new NotImplementedException();
		}
	}

	private enum LastSaid
	{
		BOAT,
		SAME,
		OTHER
	}

	private Maybe<(LocationTypes, Roles)> ability_result = new Maybe<(LocationTypes, Roles)>();

	private LastSaid last_said = LastSaid.SAME;

	public override Roles role => Roles.SPOTTER;

	public override string english_name => "Spotter";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick a " + Keywords.LOCATION.toString() + " and a " + Keywords.ROLE.toString() + " from the " + Keywords.SUSPECT_LIST.toString() + ". I " + Keywords.ANNOUNCE.toString() + " which of the " + Keywords.BOAT.toString() + " and the picked " + Keywords.LOCATION.toString() + " is closer to the picked " + Keywords.ROLE.toString() + ".\nMy " + Keywords.ABILITY.toString() + " can only be used when I am on the " + Keywords.BOAT.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "If the picked " + Keywords.ROLE.toString() + " is " + Keywords.NOT_IN_PLAY.toString() + ", I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\"."));
			list.Add((DescriptionType.SPECIAL, "If the " + Keywords.BOAT.toString() + " and the picked " + Keywords.LOCATION.toString() + " are the same distance away from the picked " + Keywords.ROLE.toString() + ", I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_2 + "\"."));
			list.Add((DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounceOppositeOfTrue ?? ""));
			return list;
		}
	}

	public override bool hasInfo
	{
		get
		{
			if (ability_result.is_some)
			{
				return ability_exhausted;
			}
			return false;
		}
	}

	public List<IHaveAbility> abilities => new List<IHaveAbility>
	{
		new RadarLocationAbility(),
		new RadarSuspectAbility()
	};

	public SpecialAbilityType ability_type => SpecialAbilityType.NONE;

	public bool abilityExhausted
	{
		get
		{
			if (!ability_exhausted)
			{
				if (base.docks_case != null)
				{
					return base.docks_case.boat.position != base.board_position;
				}
				return true;
			}
			return true;
		}
	}

	public int numberTargets => 2;

	public override bool has_hover_focus => hasInfo;

	private string loc_no_info_key => $"{role} [info_no]";

	private string loc_same_info_key => $"{role} [info_sm]";

	public Spotter(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Spotter(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			if (_save.unique_data == "f")
			{
				ability_result = new Maybe<(LocationTypes, Roles)>();
				return;
			}
			string[] array = _save.unique_data.Split(',');
			ability_result = ((LocationTypes)int.Parse(array[0]), (Roles)int.Parse(array[1])).maybe();
			last_said = (LastSaid)int.Parse(array[2]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			ability_result = new Maybe<(LocationTypes, Roles)>();
			last_said = LastSaid.SAME;
		}
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type == DescriptionType.SPECIAL)
		{
			return _description.Replace(RoleData.loc_marker_1, checkTranslationWithData(loc_no_info_key, englishNoInfo, "#")).Replace(RoleData.loc_marker_2, checkTranslationWithData(loc_same_info_key, englishSameInfo, "#"));
		}
		return base.fillExtraDescription(_description, _type);
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address == base.address)
		{
			if (_data.Count < 2 || !(_data[0] is LocationAbilityData locationAbilityData) || !(_data[1] is SuspectAbilityData suspectAbilityData))
			{
				Debug.LogError($"{role} ability was given too few elements or elements of wrong type.");
			}
			else
			{
				ability_result = (locationAbilityData.location, suspectAbilityData.role).maybe();
			}
		}
	}

	public string getAbilityPrompt()
	{
		return "";
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		if (!ability_result.is_some)
		{
			Debug.LogError($"{role} trying to generate info before ability has been used!");
			return "";
		}
		Dictionary<int, RoleData> address_occupents = _snap.address_occupents;
		Maybe<KeyValuePair<int, RoleData>> role_picked = address_occupents.ToList().firstIfSome((KeyValuePair<int, RoleData> _kvp) => _kvp.Value.role == ability_result.value.Item2);
		if (!role_picked.is_some)
		{
			if (base.has_bad_info)
			{
				return getRandomWrongInfo(ability_result.value.Item1, ability_result.value.Item2.toString());
			}
			return checkTranslationWithData(loc_no_info_key, englishNoInfo, ability_result.value.Item2.toString());
		}
		LocationData locationData = _snap.board.getLocationsInPlay()[ability_result.value.Item1];
		int num = _snap.docks_payload.boat.position.cardinalDistance(role_picked.value.Value.getBoardPosition());
		int num2 = locationData.getBoardPosition().cardinalDistance(role_picked.value.Value.getBoardPosition());
		if (num == num2)
		{
			if (base.has_bad_info)
			{
				return getRandomWrongInfo(locationData.location_type, role_picked.value.Value.name_coloured);
			}
			last_said = LastSaid.SAME;
			return checkTranslationWithData(loc_same_info_key, englishSameInfo, role_picked.value.Value.name_coloured);
		}
		last_said = (((num2 <= num || base.has_bad_info) && (num2 >= num || !base.has_bad_info)) ? LastSaid.OTHER : LastSaid.BOAT);
		string bol = ((last_said == LastSaid.BOAT) ? Keywords.BOAT.toString() : locationData.location_type.toString());
		return checkTranslationWithReplace(() => englishInfo(role_picked.value.Value.name_coloured, bol), () => role_picked.value.Value.name_coloured, () => bol);
	}

	private string getRandomWrongInfo(LocationTypes _loc, string _role_name)
	{
		last_said = ((random.Next(0, 2) != 1) ? LastSaid.OTHER : LastSaid.BOAT);
		string bol = ((last_said == LastSaid.BOAT) ? Keywords.BOAT.toString() : _loc.toString());
		return checkTranslationWithReplace(() => englishInfo(_role_name, bol), () => _role_name, () => bol);
	}

	private string englishInfo(string _d1, string _d2)
	{
		return "The " + _d1 + " is closer to the " + _d2;
	}

	private string englishSameInfo(string _d1)
	{
		return "The " + _d1 + " is cornered!";
	}

	private string englishNoInfo(string _d1)
	{
		return "The " + _d1 + " has evaded us.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		int num = _position.cardinalDistance(_snap.board.getLocationsInPlay()[ability_result.value.Item1].getBoardPosition());
		int num2 = _position.cardinalDistance(base.docks_case.boat.position);
		return last_said switch
		{
			LastSaid.BOAT => num2 < num, 
			LastSaid.SAME => num2 == num, 
			LastSaid.OTHER => num < num2, 
			_ => false, 
		};
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.dead)
		{
			return _board;
		}
		resetInfo();
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getUniqueSaveData()
	{
		if (!ability_result.is_some)
		{
			return "f";
		}
		return $"{(int)ability_result.value.Item1},{(int)ability_result.value.Item2},{(int)last_said}";
	}
}
