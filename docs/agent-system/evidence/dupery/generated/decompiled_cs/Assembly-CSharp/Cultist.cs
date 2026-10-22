using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Cultist : DocksRoleData, IHaveRoleAbility, IHaveAbility
{
	private const int fuel_at_stake = 2;

	private const int nb_targets = 1;

	private List<int> targets = new List<int>();

	private int fuel_returned;

	public override Roles role => Roles.CULTIST;

	public override string english_name => "Cultist";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick a " + Keywords.ROLE.toString() + ". I " + Keywords.KILL.toString() + " them. If they were " + TextHelper.pretending + ", I give you " + RoleData.loc_marker_1 + " " + Keywords.FUEL.toString() + ". Otherwise, I steal " + RoleData.loc_marker_2 + " " + Keywords.FUEL.toString() + ". " + TextHelper.whenIAmLyingOrTainted + ", I always steal " + RoleData.loc_marker_2 + " " + Keywords.FUEL.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, "I always truthfully " + Keywords.ANNOUNCE.toString() + " if I gave or stole " + Keywords.FUEL.toString() + ", even when I am " + TextHelper.lyingOrTainted + "."));
			return list;
		}
	}

	public override bool hasInfo => ability_exhausted;

	public override bool has_hover_focus
	{
		get
		{
			if (ability_exhausted)
			{
				return targets.Count > 0;
			}
			return false;
		}
	}

	bool IHaveAbility.abilityExhausted => ability_exhausted;

	int IHaveAbility.numberTargets => 1;

	bool IHaveRoleAbility.allowSelfTarget => false;

	private string loc_empty_info_key => $"{role} [info_empty]";

	public Cultist(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Cultist(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split('#');
			targets = array[0].fromStringCommaSeperate();
			fuel_returned = int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}!\nSave: {_save.unique_data}\nError: {arg}");
			targets = new List<int>();
			fuel_returned = 0;
		}
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 2.ToString()).Replace(RoleData.loc_marker_2, 2.ToString());
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (targets.Count < 1)
		{
			Debug.LogError($"{role} failed to generate info. Targets no set up!");
			return "";
		}
		if (fuel_returned > 0)
		{
			return checkTranslationWithData(englishInfo, targets[0]);
		}
		return checkTranslationWithData(loc_empty_info_key, englishFailInfo, targets[0]);
	}

	private string englishInfo(string _d1)
	{
		return "The sacrifice of #" + _d1 + " was a success.";
	}

	private string englishFailInfo(string _d1)
	{
		return "The sacrifice of #" + _d1 + " was a failure.";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		if (_target_addresses.Count != 1)
		{
			Debug.LogError($"{role} ability failed to be used. Expecting {1} targets, got {_target_addresses.Count}!");
			return _board;
		}
		targets = _target_addresses.copy();
		base.docks_case.killAddress(targets[0], this);
		if (base.has_bad_info)
		{
			fuel_returned = -2;
			base.docks_case.loseFuel(-fuel_returned);
			return _board;
		}
		Dictionary<int, RoleData> rolesInPlay = _board.getRolesInPlay();
		fuel_returned = (rolesInPlay[targets[0]].getIsDisguised() ? 2 : (-2));
		if (fuel_returned > 0)
		{
			base.docks_case.addFuel(fuel_returned);
		}
		else if (fuel_returned < 0)
		{
			base.docks_case.loseFuel(-fuel_returned);
		}
		return _board;
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return targets.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	bool IHaveRoleAbility.validateTarget(RoleData _roll_candidate)
	{
		if (_roll_candidate.getAddress() != base.address)
		{
			return !_roll_candidate.getIsDead();
		}
		return false;
	}

	string IHaveAbility.getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(1);
	}

	public override string getUniqueSaveData()
	{
		return $"{targets.toStringCommaSeperated()}#{fuel_returned}";
	}
}
