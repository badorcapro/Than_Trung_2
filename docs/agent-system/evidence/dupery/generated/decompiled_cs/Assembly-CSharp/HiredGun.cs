using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class HiredGun : CasinoRoleData, IHaveRoleAbility, IHaveAbility
{
	private const int ability_cost = 4;

	private int target = -1;

	private bool success;

	public override Roles role => Roles.HIRED_GUN;

	public override string english_name => "Hired Gun";

	public override string english_description => TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.ROLE.toString() + ". I " + Keywords.KILL.toString() + " them.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I do not " + Keywords.KILL.toString() + " but you still pay the cost of using the " + Keywords.ABILITY.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => ability_exhausted;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public bool allowSelfTarget => true;

	public override bool has_hover_focus
	{
		get
		{
			if (ability_exhausted)
			{
				return target > 0;
			}
			return false;
		}
	}

	public override bool has_truth_hover_focus
	{
		get
		{
			if (ability_exhausted)
			{
				return success;
			}
			return false;
		}
	}

	public HiredGun(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public HiredGun(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			target = int.Parse(array[0]);
			success = array[1] == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"{role} Loading Failed!\nSave: {_save.unique_data}\n Error: {arg}");
			target = -1;
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

	public bool validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(1);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		base.casino_case.spendChips(Mathf.FloorToInt(4f * base.casino_case.cost_multiplyer));
		target = _target_addresses[0];
		if (base.has_bad_info)
		{
			return _board;
		}
		success = true;
		base.case_ref.killAddress(target, ((RoleData)this).maybe());
		return _board;
	}

	protected override string generateCasinoInfoString(CasinoCaseSnapshot _snap)
	{
		return checkTranslationWithData(englishInfo, target);
	}

	private string englishInfo(string _data)
	{
		return "I shot #" + _data;
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == target;
		}
		return false;
	}

	public override string getTruthString()
	{
		if (!success)
		{
			return base.getTruthString();
		}
		return TextHelper.killedOneLocalised(target);
	}

	public override bool checkEndInfoHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == target;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return string.Format("{0},{1}", target, success ? "t" : "f");
	}
}
