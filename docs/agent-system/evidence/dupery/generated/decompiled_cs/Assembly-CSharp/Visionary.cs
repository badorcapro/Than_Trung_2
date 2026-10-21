using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Visionary : CasinoRoleData, IHaveRoleAbility, IHaveAbility
{
	private const int ability_cost = 8;

	private int target_1 = -1;

	private int target_2 = -1;

	private int target_3 = -1;

	public override Roles role => Roles.VISIONARY;

	public override string english_name => "Visionary";

	public override string english_description => TextHelper.ability_with_cost_marker + ": Pick 3 " + TextHelper.roles + ". If they are the same " + Keywords.ALIGNMENT.toString() + ", I " + Keywords.ANNOUNCE.toString() + " \"" + englishInfoAllSame("x", "y", "z") + "\", otherwise I announce which ones are " + Alignments.EVIL.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I will always " + Keywords.ANNOUNCE.toString() + " 1 or 2 " + TextHelper.addresses + " as being " + Alignments.EVIL.toString() + ". My statement will always be different to the true statement."));
			return list;
		}
	}

	public override bool hasInfo => ability_exhausted;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 3;

	public bool allowSelfTarget => true;

	private string loc_info_1_key => $"{role} [info_1]";

	private string loc_info_2_key => $"{role} [info_2]";

	private string loc_info_same_key => $"{role} [info_same]";

	public Visionary(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Visionary(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, Mathf.FloorToInt(8f * (_snapshot as CasinoCaseSnapshot).casino_payload.cost_multi).ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 8.ToString());
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(3);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		base.casino_case.spendChips(Mathf.FloorToInt(8f * base.casino_case.cost_multiplyer));
		target_1 = _target_addresses[0];
		target_2 = _target_addresses[1];
		target_3 = _target_addresses[2];
		return _board;
	}

	protected override string generateCasinoInfoString(CasinoCaseSnapshot _snap)
	{
		List<int> list = new List<int> { target_1, target_2, target_3 };
		Dictionary<int, RoleData> occupents = _snap.address_occupents;
		List<int> evil_roles = list.Where((int _a) => occupents[_a].getVisualAlignment() == Alignments.EVIL).ToList();
		if (base.has_bad_info)
		{
			if (evil_roles.Count == 3 || evil_roles.Count == 0)
			{
				return info(list.getRandomElementsFromList(random, random.Next(1, 3)));
			}
			list = list.Where((int _t) => !evil_roles.Contains(_t)).ToList();
			return info(list);
		}
		return info(evil_roles);
	}

	private string englishInfoAllSame(string _data_1, string _data_2, string _data_3)
	{
		return "#" + _data_1 + ", #" + _data_2 + " and #" + _data_3 + " work together.";
	}

	private string englishInfo2Evil(string _data_1, string _data_2)
	{
		return "#" + _data_1 + " and #" + _data_2 + " are evil.";
	}

	private string englishInfo1Evil(string _data_1)
	{
		return "#" + _data_1 + " is evil.";
	}

	private string info(List<int> _addresses)
	{
		if (_addresses.Count == 0)
		{
			return checkTranslationWithReplace(loc_info_same_key, () => englishInfoAllSame(target_1.ToString(), target_2.ToString(), target_3.ToString()), target_1, target_2, target_3);
		}
		if (_addresses.Count == 1)
		{
			return checkTranslationWithData(loc_info_1_key, englishInfo1Evil, _addresses[0]);
		}
		if (_addresses.Count == 2)
		{
			return checkTranslationWithReplace(loc_info_2_key, () => englishInfo2Evil(_addresses[0].ToString(), _addresses[1].ToString()), _addresses[0], _addresses[1]);
		}
		return checkTranslationWithReplace(loc_info_same_key, () => englishInfoAllSame(_addresses[0].ToString(), _addresses[1].ToString(), _addresses[2].ToString()), _addresses[0], _addresses[1], _addresses[2]);
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
