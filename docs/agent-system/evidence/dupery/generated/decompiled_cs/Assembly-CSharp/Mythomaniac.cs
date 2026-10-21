using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Mythomaniac : RoleData, IHaveSpecialSpecificAbility, IHaveSpecialAbility, IHaveAbility
{
	private Maybe<Roles> ability_result = new Maybe<Roles>();

	public override Roles role => Roles.MYTHOMANIAC;

	public override string english_name => "Mythomaniac";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick an " + TextHelper.innocentRole + " from the " + Keywords.SUSPECT_LIST.toString() + ". I " + Keywords.PRETEND.toString() + " to be them.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, "I will " + Keywords.PRETEND.toString() + " to be the picked " + Keywords.ROLE.toString() + " even when I am " + TextHelper.lyingOrTainted + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public SpecialAbilityType ability_type => SpecialAbilityType.SUSPECT;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public Mythomaniac(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Mythomaniac(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectSuspectOfClassLocalised(RoleClassifications.INNOCENT);
	}

	public bool validateSelectedSpecialData(AbilityData _data)
	{
		if (_data is SuspectAbilityData suspectAbilityData)
		{
			return suspectAbilityData.role.getClassificationFromRoleType() == RoleClassifications.INNOCENT;
		}
		return false;
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address == base.address && (!base.is_true_self || !disguise.is_some))
		{
			if (_data.Count == 0 || !(_data[0] is SuspectAbilityData suspectAbilityData))
			{
				Debug.LogError($"{role} special ability data list is empty or not of correct type!");
			}
			else if (suspectAbilityData.role.getClassificationFromRoleType() != 0)
			{
				Debug.LogError($"{role} chosen role with ability is not innocent!");
			}
			else
			{
				ability_result = suspectAbilityData.role.maybe();
			}
		}
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address || !ability_result.is_some)
		{
			return _board;
		}
		overrideWithNewDisguise(ability_result.value);
		ability_result = new Maybe<Roles>();
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return "";
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
