using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Empath : RoleData, IHaveRoleAbility, IHaveAbility
{
	private int target = -1;

	public override Roles role => Roles.EMPATH;

	public override string english_name => "Empath";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick a " + Keywords.ROLE.toString() + ". If they are either a " + TextHelper.lyingOrTainted + " " + TextHelper.evilRole + " or a " + Keywords.TRUTHFUL.toString() + " " + TextHelper.goodRole + ", I " + Keywords.ANNOUNCE.toString() + " \"" + infoCommittedEnglish("") + "\", otherwise I " + Keywords.ANNOUNCE.toString() + " \"" + infoConfusedEnglish("") + "\".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounceOppositeOfTrue) };

	public override string credits => "ExistingHuman";

	bool IHaveAbility.abilityExhausted => ability_exhausted;

	int IHaveAbility.numberTargets => 1;

	bool IHaveRoleAbility.allowSelfTarget => true;

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

	private string loc_committed_info_key => $"{role} [comm_info]";

	private string loc_confused_info_key => $"{role} [conf_info]";

	public Empath(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Empath(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			target = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading failed! {role}. Error: {arg}");
			target = -1;
		}
	}

	protected override bool getEnglishNamePrefixOption()
	{
		return false;
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	bool IHaveRoleAbility.validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	string IHaveAbility.getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(1);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		target = _target_addresses[0];
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
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
		if (target == -1)
		{
			Debug.LogError($"Trying to get info string before target is selected!!! {role}.");
			return "";
		}
		RoleData roleData = _snap.address_occupents[target];
		bool flag = (roleData.getVisualAlignment() == Alignments.EVIL && roleData.getIsLyingOrTainted()) || (roleData.getVisualAlignment() == Alignments.GOOD && !roleData.has_bad_info);
		if (base.has_bad_info)
		{
			flag = !flag;
		}
		if (flag)
		{
			return checkTranslationWithData(loc_committed_info_key, infoCommittedEnglish, target);
		}
		return checkTranslationWithData(loc_confused_info_key, infoConfusedEnglish, target);
	}

	private string infoCommittedEnglish(string _data)
	{
		return "#" + _data + " is committed!";
	}

	private string infoConfusedEnglish(string _data)
	{
		return "#" + _data + " is confused!";
	}

	public override string getUniqueSaveData()
	{
		return target.ToString();
	}
}
