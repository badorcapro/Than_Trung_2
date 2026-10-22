using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Vigilante : RoleData, IHaveRoleAbility, IHaveAbility
{
	public int target = -1;

	public bool always_kill;

	public override Roles role => Roles.VIGILANTE;

	public override string english_name => "Vigilante";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick a " + Keywords.ROLE.toString() + ". If the selected " + Keywords.ROLE.toString() + " is " + Alignments.EVIL.toString() + " I " + Keywords.KILL.toString() + " them.\nOtherwise nothing happens.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I can " + Keywords.TARGET.toString() + " myself with my " + Keywords.ABILITY.toString() + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I always miss."));
			return list;
		}
	}

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

	public override bool hasInfo => ability_exhausted;

	bool IHaveAbility.abilityExhausted => ability_exhausted;

	int IHaveAbility.numberTargets => 1;

	bool IHaveRoleAbility.allowSelfTarget => true;

	private string loc_fail_info_key => $"{role} [fail]";

	public Vigilante(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Vigilante(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			target = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! Error: {arg}");
			target = -1;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HAS_ABILITY);
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address == base.address)
		{
			target = _target_addresses[0];
			if (!base.has_bad_info && (always_kill || _board.getRolesInPlay()[target].getVisualAlignment() == Alignments.EVIL))
			{
				_board = base.case_ref.killAddress(target, ((RoleData)this).maybe()).board;
			}
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

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (target == -1 && !base.has_bad_info)
		{
			Debug.LogError("Vigilante Target set to -1! This is not possible!");
			return "";
		}
		if (base.has_bad_info || (_snap.board.getRolesInPlay()[target].getVisualAlignment() != Alignments.EVIL && !always_kill))
		{
			return checkTranslationWithData(loc_fail_info_key, getNoInfoEnglish, target);
		}
		return checkTranslationWithData(getInfoEnglish, target);
	}

	private string getInfoEnglish(string _data)
	{
		return "Justice came for #" + _data + ".";
	}

	private string getNoInfoEnglish(string _data)
	{
		return "*I missed #" + _data + "*";
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
