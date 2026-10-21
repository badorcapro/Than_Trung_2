using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Marine : DocksRoleData, IHaveRoleAbility, IHaveAbility
{
	private int target = -1;

	public override Roles role => Roles.MARINE;

	public override string english_name => "Marine";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick a " + Keywords.ROLE.toString() + ". I " + Keywords.ANNOUNCE.toString() + " their " + Keywords.CLASSIFICATION.toString() + ". My " + Keywords.ABILITY.toString() + " can only be used when I am on the " + Keywords.BOAT.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I will always " + Keywords.ANNOUNCE.toString() + " an incorrect random " + Keywords.CLASSIFICATION.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => target != -1;

	public override bool has_hover_focus
	{
		get
		{
			if (ability_exhausted)
			{
				return target != -1;
			}
			return false;
		}
	}

	bool IHaveAbility.abilityExhausted
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

	int IHaveAbility.numberTargets => 1;

	bool IHaveRoleAbility.allowSelfTarget => true;

	public Marine(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Marine(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		target = RoleHelper.tryLoadSingleValueFromUniqueData(role, _save);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (target == -1)
		{
			Debug.LogError($"Trying to get info before shot has been made! {role}!");
			return "";
		}
		RoleClassifications visualClassification = _snap.board.getRolesInPlay()[target].getVisualClassification();
		if (base.has_bad_info)
		{
			RoleClassifications randomElementFromList = new List<RoleClassifications>().addAll().remove(visualClassification).getRandomElementFromList(random);
			return info(target, randomElementFromList);
		}
		return info(target, visualClassification);
	}

	private string info(int _add, RoleClassifications _class)
	{
		return LocalisationHelper.checkOption(checkTranslationWithReplace(() => englishInfo(_add.ToString(), _class.toStringPlain()), () => _add.ToString(), () => _class.toStringPlain()), _class.getPrefixOption());
	}

	private string englishInfo(string _data, string _data_2)
	{
		return "#" + _data + " is a{#/n} " + _data_2 + ".";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address == base.address)
		{
			target = _target_addresses[0];
		}
		return _board;
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return _occupent.maybe_a.value.getAddress() == target;
	}

	bool IHaveRoleAbility.validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	string IHaveAbility.getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(1);
	}

	public override string getUniqueSaveData()
	{
		return target.ToString();
	}
}
