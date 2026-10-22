using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Supplier : BackAlleyRoleData, IHaveRoleAbility, IHaveAbility
{
	private Maybe<BackAlleysItem> stolen_item = new Maybe<BackAlleysItem>();

	private bool returned_stolen_item;

	private Maybe<BackAlleysItemType> item_given = new Maybe<BackAlleysItemType>();

	public override Roles role => Roles.SUPPLIER;

	public override string english_name => "Supplier";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": I give you a random " + Keywords.ITEM.toString() + ". " + TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.STEAL.toString() + " a random " + Keywords.ITEM.toString() + " instead.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.SPECIAL, TextHelper.iAmSelfConfirm) };

	public override bool hasInfo => false;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public bool allowSelfTarget => true;

	private string loc_stolen_truth => $"{role} [t_stolen]";

	public Supplier(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Supplier(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			if (_save.unique_data == "f")
			{
				stolen_item = new Maybe<BackAlleysItem>();
				item_given = new Maybe<BackAlleysItemType>();
				return;
			}
			switch (_save.unique_data[0])
			{
			case 's':
				item_given = new Maybe<BackAlleysItemType>();
				returned_stolen_item = _save.unique_data[1] == 't';
				stolen_item = BackAlleysItem.load(_save.unique_data.Substring(2), delegate
				{
				}, random).maybe();
				break;
			case 'g':
				item_given = ((BackAlleysItemType)int.Parse(_save.unique_data.Substring(1))).maybe();
				stolen_item = new Maybe<BackAlleysItem>();
				break;
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			stolen_item = new Maybe<BackAlleysItem>();
			item_given = new Maybe<BackAlleysItemType>();
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new HashSet<RoleGenerationMarkers>
		{
			RoleGenerationMarkers.SELF_CONFIRM,
			RoleGenerationMarkers.HAS_ABILITY
		});
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		return _roll_candidate.getAddress() == base.address;
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_reselectToConfirmLocalised;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		if (base.has_bad_info)
		{
			stolen_item = base.back_alley_case.pouch.stealItem(random);
			return _board;
		}
		Debug.Log("Probably want to change how I choose the item to give...");
		item_given = new List<BackAlleysItemType>().addAll().getRandomElementFromList(random).maybe();
		base.back_alley_case.pouch.gainItem(item_given.value, random);
		return _board;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address != base.address || !stolen_item.is_some || returned_stolen_item)
		{
			return _board;
		}
		base.back_alley_case.pouch.gainItem(stolen_item.value);
		returned_stolen_item = true;
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	public override string getTruthString()
	{
		return (stolen_item.is_some ? (checkTranslationWithData(loc_stolen_truth, englishTruthStolen, stolen_item.value.name) + "\n") : (item_given.is_some ? (checkTranslationWithData(base.loc_default_truth_key, englishTruthGave, item_given.value.createItem(random).name) + "\n") : "")) + base.getTruthString();
	}

	private string englishTruthGave(string _data)
	{
		return "I gave you a " + _data + "!";
	}

	private string englishTruthStolen(string _data)
	{
		return "I stole your " + _data + "!";
	}

	public override string getUniqueSaveData()
	{
		if (!stolen_item.is_some)
		{
			if (!item_given.is_some)
			{
				return "f";
			}
			return $"g{(int)item_given.value}";
		}
		return "s" + (returned_stolen_item ? "t" : "f") + stolen_item.value.toSaveData();
	}
}
