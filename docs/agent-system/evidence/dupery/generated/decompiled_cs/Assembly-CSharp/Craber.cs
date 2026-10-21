using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Craber : DocksRoleData, IHaveSpecialAbility, IHaveAbility
{
	private int target = -1;

	public override Roles role => Roles.CRABER;

	public override string english_name => "Crabber";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick an empty position on the " + Keywords.BOARD.toString() + ". If it contains a " + TextHelper.hiddenRole + ", I " + Keywords.DREDGE.toString() + " them.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I never " + Keywords.DREDGE.toString() + ".") };

	public override bool hasInfo => ability_exhausted;

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

	public SpecialAbilityType ability_type => SpecialAbilityType.EMPTY_SLOT;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	private string loc_no_info_key => $"{role} [info_no]";

	public Craber(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Craber(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		target = RoleHelper.tryLoadSingleValueFromUniqueData(role, _save);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new List<AdvancedGenerationConstraint>
		{
			new InPlayRequireRoleGC(RoleGenerationMarkers.HIDES, 1, DisguiseConstraintType.NEVER_IGNORE),
			new LeadRequireGC(new List<RoleClassifications>
			{
				RoleClassifications.MEDDLER,
				RoleClassifications.UNDERLING
			}, RoleGenerationMarkers.HIDES, 2)
		});
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (target == -1)
		{
			return checkTranslation(loc_no_info_key, englishNoInfo);
		}
		return checkTranslationWithData(englishInfo, target);
	}

	private string englishInfo(string _data)
	{
		return "I dredged #" + _data + ".";
	}

	private string englishNoInfo()
	{
		return "There is nothing to dredge there.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return _occupent.maybe_a.value.getAddress() == target;
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectEmptyPositionLocalised(numberTargets);
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address != base.address || base.has_bad_info)
		{
			return;
		}
		if (_data.Count < 1 || !(_data[0] is EmptySlotAbilityData emptySlotAbilityData) || !_board.ContainsKey(emptySlotAbilityData.position))
		{
			Debug.LogError($"{role} got given empty ability data or data of wrong type or invalid data!");
			return;
		}
		Maybe<Either<RoleData, LocationData>> maybe = _board[emptySlotAbilityData.position];
		if (maybe.is_some && !maybe.value.is_b)
		{
			base.docks_case.dredgeRole(maybe.value.maybe_a.value, this);
			target = maybe.value.maybe_a.value.getAddress();
		}
	}

	public override string getUniqueSaveData()
	{
		return target.ToString();
	}
}
