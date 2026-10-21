using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Hunter : CasinoRoleData, IHaveMultiAbility, IHaveSpecialAbility, IHaveAbility
{
	public class HunterSuspectAbility : IHaveSpecialAbility, IHaveAbility
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

	public class HunterRoleAbility : IHaveRoleAbility, IHaveAbility
	{
		public bool allowSelfTarget => true;

		public bool abilityExhausted => false;

		public int numberTargets => 1;

		public string getAbilityPrompt()
		{
			return TextHelper.ab_selectRolesLocalised(1);
		}

		public bool validateTarget(RoleData _roll_candidate)
		{
			return true;
		}
	}

	private const int ability_cost = 4;

	private Maybe<(int, Roles, bool)> ability_selection = new Maybe<(int, Roles, bool)>();

	public override Roles role => Roles.HUNTER;

	public override string english_name => "Hunter";

	public override string english_description => TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.ROLE.toString() + " and a " + Keywords.ROLE.toString() + " from the " + Keywords.SUSPECT_LIST.toString() + ". I " + Keywords.KILL.toString() + " the " + Keywords.ROLE.toString() + " picked if their identity matches the " + Keywords.ROLE.toString() + " picked from the " + Keywords.SUSPECT_LIST.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.KILL.toString() + " the " + Keywords.ROLE.toString() + " if their identity does not match the " + Keywords.ROLE.toString() + " picked from the " + Keywords.SUSPECT_LIST.toString() + "."));
			return list;
		}
	}

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public List<IHaveAbility> abilities => new List<IHaveAbility>
	{
		new HunterRoleAbility(),
		new HunterSuspectAbility()
	};

	public SpecialAbilityType ability_type => SpecialAbilityType.NONE;

	public override bool hasInfo
	{
		get
		{
			if (ability_exhausted)
			{
				return ability_selection.is_some;
			}
			return false;
		}
	}

	public override bool has_hover_focus
	{
		get
		{
			if (ability_selection.is_some)
			{
				return ability_selection.value.Item3;
			}
			return false;
		}
	}

	public override bool has_truth_hover_focus => has_hover_focus;

	private string loc_missed_key => $"{role} [info_miss]";

	public Hunter(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Hunter(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		if (_save.unique_data == "f")
		{
			ability_selection = new Maybe<(int, Roles, bool)>();
			return;
		}
		try
		{
			string[] array = _save.unique_data.Split(',');
			ability_selection = (int.Parse(array[0]), (Roles)int.Parse(array[1]), array[2] == "t").maybe();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading {role} failed!\nSave: {_save.unique_data}\nError: {arg}");
			ability_selection = new Maybe<(int, Roles, bool)>();
		}
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, Mathf.FloorToInt(4f * (_snapshot as CasinoCaseSnapshot).casino_payload.cost_multi).ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 4.ToString());
	}

	public string getAbilityPrompt()
	{
		return "";
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address != base.address)
		{
			return;
		}
		if (_data.Count != 2 || !(_data[0] is AddressAbilityData addressAbilityData) || !(_data[1] is SuspectAbilityData suspectAbilityData))
		{
			Debug.LogError($"{role} ability did not return valid ability data!");
			return;
		}
		RoleData roleData = _board.getRolesInPlay()[addressAbilityData.address];
		bool flag = roleData.role == suspectAbilityData.role;
		if (base.has_bad_info)
		{
			flag = !flag;
		}
		if (flag)
		{
			base.casino_case.killAddress(roleData.getAddress(), this);
		}
		ability_selection = (roleData.getAddress(), suspectAbilityData.role, flag).maybe();
	}

	protected override string generateCasinoInfoString(CasinoCaseSnapshot _snap)
	{
		if (!ability_selection.is_some)
		{
			Debug.LogError($"Trying to generate info before ability has been used! {role}");
			return "";
		}
		if (ability_selection.value.Item3)
		{
			return checkTranslationWithData(englishInfo, ability_selection.value.Item1);
		}
		return checkTranslationWithData(loc_missed_key, englishMiss, ability_selection.value.Item1);
	}

	private string englishInfo(string _data)
	{
		return "I slayed #" + _data + ".";
	}

	private string englishMiss(string _data)
	{
		return "#" + _data + " is not your target.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == ability_selection.value.Item1;
		}
		return false;
	}

	public override string getTruthString()
	{
		return ((ability_selection.is_some && ability_selection.value.Item3) ? TextHelper.killedOneLocalised(ability_selection.value.Item1) : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		return checkHoverFocus(_snap, _position, _occupent);
	}

	public override string getUniqueSaveData()
	{
		if (!ability_selection.is_some)
		{
			return "f";
		}
		return string.Format("{0},{1},{2}", ability_selection.value.Item1, ability_selection.value.Item2, ability_selection.value.Item3 ? "t" : "f");
	}
}
