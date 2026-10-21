using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Localisation;
using UnityEngine;

namespace BackAlleyItems;

public class SkepticLoop : BackAlleysItem, IHaveRoleAbility, IHaveAbility
{
	private const int starting_usages = 3;

	public override BackAlleysItemType type => BackAlleysItemType.SKEPTIC_LOOP;

	public override BackAlleysItemColour colour => BackAlleysItemColour.MISCHEVIOUS;

	public override BackAlleysItemCost cost => BackAlleysItemCost.NORMAL;

	protected override string english_name => "Skeptic Loop";

	protected override string english_description => $"Pick a role. Learn their {Keywords.CLASSIFICATION.toString()}. Has {3} uses.";

	public override bool is_active => true;

	public bool abilityExhausted => base.uses_remaining <= 0;

	public int numberTargets => 1;

	public bool allowSelfTarget => false;

	private string loc_info_key => $"{type} [info]";

	private string loc_ability_key => $"{type} [abi]";

	public SkepticLoop(System.Random _rng, int _usages = -1)
		: base(_rng, (_usages == -1) ? 3 : _usages)
	{
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(1);
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		return !_roll_candidate.getIsDead();
	}

	public override void useItemAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<AbilityData> _data, BackAlleysCase _case)
	{
		int address = (_data[0] as AddressAbilityData).address;
		_case.pouch.setItemInfo(getInfo(address, _board.getRolesInPlay()[address].getVisualClassification()));
		spendUse();
	}

	private string getInfo(int _address, RoleClassifications _class)
	{
		return LocalisationHelper.checkOption(base.localisation_asset.checkTranslationWithReplace(loc_info_key, () => englishInfo(_address.ToString(), _class.toString()), true, _address.ToString(), _class.toString()), _class.getPrefixOption());
	}

	private string englishInfo(string _data_1, string _data_2)
	{
		return "#" + _data_1 + " is a{#/n} " + _data_2;
	}

	protected override string getUniqueSaveData()
	{
		return "";
	}
}
