using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Bouncer : CasinoRoleData, IHaveRoleAbility, IHaveAbility
{
	private enum B_InfoType
	{
		TRUSTWORTHY,
		PRETENDING,
		LYING,
		TAINTED
	}

	private const int ability_cost = 4;

	private int target = -1;

	public override Roles role => Roles.BOUNCER;

	public override string english_name => "Bouncer";

	public override string english_description => TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.ROLE.toString() + ". I " + Keywords.ANNOUNCE.toString() + " if they are " + TextHelper.pretending + ", " + TextHelper.lyingOrTainted + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I always " + Keywords.ANNOUNCE.toString() + " only 1 statement about the picked " + Keywords.ROLE.toString() + " even if multiple are true."));
			list.Add((DescriptionType.SPECIAL, "When the picked " + Keywords.ROLE.toString() + " is not " + TextHelper.pretending + ", " + TextHelper.lyingOrTainted + ", I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\"."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a random statement that is false."));
			return list;
		}
	}

	public override bool hasInfo => ability_exhausted;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public bool allowSelfTarget => true;

	private string loc_pretend_info_key => $"{role} [info_pre]";

	private string loc_lie_info_key => $"{role} [info_lie]";

	private string loc_taint_info_key => $"{role} [info_tai]";

	public Bouncer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Bouncer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, Mathf.FloorToInt(4f * (_snapshot as CasinoCaseSnapshot).casino_payload.cost_multi).ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 4.ToString());
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type != DescriptionType.SPECIAL)
		{
			return _description;
		}
		return _description.Replace(RoleData.loc_marker_1, checkTranslationWithData(englishInfoGood, ""));
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
		return _board;
	}

	protected override string generateCasinoInfoString(CasinoCaseSnapshot _snap)
	{
		if (target == -1)
		{
			Debug.LogError($"Trying to generate info string before target has been picked! {role}!");
			return "";
		}
		RoleData roleData = _snap.address_occupents[target];
		List<B_InfoType> list = new List<B_InfoType>();
		if (roleData.getIsDisguised())
		{
			list.Add(B_InfoType.PRETENDING);
		}
		if (roleData.getIsLying())
		{
			list.Add(B_InfoType.LYING);
		}
		if (roleData.getIsTainted())
		{
			list.Add(B_InfoType.TAINTED);
		}
		if (list.Count == 0)
		{
			list.Add(B_InfoType.TRUSTWORTHY);
		}
		switch ((!base.has_bad_info) ? list.getRandomElementFromList(random) : new List<B_InfoType>().addAll().removeRange(list).getRandomElementFromList(random))
		{
		case B_InfoType.TRUSTWORTHY:
			return checkTranslationWithData(englishInfoGood, target);
		case B_InfoType.PRETENDING:
			return checkTranslationWithData(loc_pretend_info_key, englishInfoPretend, target);
		case B_InfoType.LYING:
			return checkTranslationWithData(loc_lie_info_key, englishInfoLie, target);
		case B_InfoType.TAINTED:
			return checkTranslationWithData(loc_taint_info_key, englishInfoTaint, target);
		default:
			Debug.LogError($"AAAAAAAAA ({role})");
			return "";
		}
	}

	private string englishInfoGood(string _data)
	{
		return "#" + _data + " checks out.";
	}

	private string englishInfoPretend(string _data)
	{
		return "#" + _data + " is pretending.";
	}

	private string englishInfoLie(string _data)
	{
		return "#" + _data + " is lying.";
	}

	private string englishInfoTaint(string _data)
	{
		return "#" + _data + " is tainted.";
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
