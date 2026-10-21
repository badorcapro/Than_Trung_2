using System;
using System.Collections.Generic;
using GRGLib.Extensions;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Tailor : RoleData, IHaveRoleAbility, IHaveAbility
{
	private int target_address_a = -1;

	private int target_address_b = -1;

	public override Roles role => Roles.TAILOR;

	public override string english_name => "Tailor";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick two " + TextHelper.roles + ". I " + Keywords.ANNOUNCE.toString() + " if they are the same " + Keywords.ALIGNMENT.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I can " + Keywords.TARGET.toString() + " myself with my " + Keywords.ABILITY.toString() + ".\nI can " + Keywords.TARGET.toString() + " " + Keywords.DEAD.toString() + ", " + Keywords.UNINVESTIGATED.toString() + ", and " + TextHelper.arrested + " " + TextHelper.roles + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I will " + Keywords.ANNOUNCE.toString() + " the opposite result to what is truthful."));
			return list;
		}
	}

	public override bool hasInfo => ability_exhausted;

	public override bool has_hover_focus
	{
		get
		{
			if (target_address_a != -1)
			{
				return target_address_b != -1;
			}
			return false;
		}
	}

	bool IHaveAbility.abilityExhausted => ability_exhausted;

	int IHaveAbility.numberTargets => 2;

	bool IHaveRoleAbility.allowSelfTarget => true;

	private string loc_same_info_key => $"{role} [info_s]";

	private string loc_different_info_key => $"{role} [info_d]";

	public Tailor(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Tailor(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		string[] array = _save.unique_data.Split(',');
		target_address_a = int.Parse(array[0]);
		target_address_b = int.Parse(array[1]);
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

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return _occupent.maybe_a.value.getAddress().equalToAny(target_address_a, target_address_b);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address == base.address)
		{
			target_address_a = _target_addresses[0];
			target_address_b = _target_addresses[1];
		}
		return _board;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		bool flag = _snap.board.getRolesInPlay()[target_address_a].getVisualAlignment() == _snap.board.getRolesInPlay()[target_address_b].getVisualAlignment();
		if (base.has_bad_info)
		{
			flag = !flag;
		}
		if (flag)
		{
			return checkTranslationWithReplace(loc_same_info_key, () => getInfoEnglishSame(target_address_a.ToString(), target_address_b.ToString()), target_address_a, target_address_b);
		}
		return checkTranslationWithReplace(loc_different_info_key, () => getInfoEnglishDifferent(target_address_a.ToString(), target_address_b.ToString()), target_address_a, target_address_b);
	}

	private string getInfoEnglishSame(string _data_1, string _data_2)
	{
		return "Role #" + _data_1 + " and #" + _data_2 + " are the same alignment.";
	}

	private string getInfoEnglishDifferent(string _data_1, string _data_2)
	{
		return "Role #" + _data_1 + " and #" + _data_2 + " are not the same alignment.";
	}

	bool IHaveRoleAbility.validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	string IHaveAbility.getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(2);
	}

	public override string getUniqueSaveData()
	{
		return $"{target_address_a},{target_address_b}";
	}
}
