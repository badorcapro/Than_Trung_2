using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Magician : CasinoRoleData, IHaveMultiAbility, IHaveSpecialAbility, IHaveAbility
{
	public class MagicianCardAbility : IHaveSpecialAbility, IHaveAbility
	{
		public SpecialAbilityType ability_type => SpecialAbilityType.CARD_ABILITY;

		public bool abilityExhausted => false;

		public int numberTargets => 1;

		public string getAbilityPrompt()
		{
			return TextHelper.ab_selectACardLocalised;
		}

		public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
		{
			throw new NotImplementedException();
		}
	}

	public class MagicianRoleAbility : IHaveRoleAbility, IHaveAbility
	{
		public bool allowSelfTarget => true;

		public bool abilityExhausted => false;

		public int numberTargets => 1;

		public string getAbilityPrompt()
		{
			return TextHelper.ab_selectRolesLocalised(1);
		}

		public bool validateTarget(RoleData _roll_candidate)
		{
			return true;
		}
	}

	private const int ability_cost = 4;

	private Maybe<(int, CasinoCard)> selection = new Maybe<(int, CasinoCard)>();

	public override Roles role => Roles.MAGICIAN;

	public override string english_name => "Magician";

	public override string english_description => TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.ROLE.toString() + " and a " + Keywords.CARD.toString() + ". Discard the " + Keywords.CARD.toString() + " and draw a new one of the " + TextHelper.suitAssociated + " with the picked " + Keywords.ROLE.toString() + "'s " + Keywords.CLASSIFICATION.toString() + ". I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.CARD.toString() + " you drew.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", the " + Keywords.CARD.toString() + " drawn will be of a random " + TextHelper.suit + " that is not " + TextHelper.associated + " with the picked " + Keywords.ROLE.toString() + "'s " + Keywords.CLASSIFICATION.toString() + "."));
			return list;
		}
	}

	public override string credits => "Rsvdark";

	public override bool hasInfo
	{
		get
		{
			if (ability_exhausted)
			{
				return selection.is_some;
			}
			return false;
		}
	}

	public SpecialAbilityType ability_type => SpecialAbilityType.NONE;

	public List<IHaveAbility> abilities => new List<IHaveAbility>
	{
		new MagicianRoleAbility(),
		new MagicianCardAbility()
	};

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 0;

	public override bool has_hover_focus => selection.is_some;

	public Magician(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Magician(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		if (_save.unique_data != "")
		{
			try
			{
				string[] array = _save.unique_data.Split(',');
				int item = int.Parse(array[0]);
				int val = int.Parse(array[1]);
				CasinoCardInfo.Suit suit = (CasinoCardInfo.Suit)int.Parse(array[2]);
				selection = (item, new CasinoCard(new CasinoCardInfo(val, suit))).maybe();
			}
			catch (Exception arg)
			{
				Debug.LogError($"Could not parse the save data ({role} | '{_save.unique_data}')!\nError: {arg}");
				selection = new Maybe<(int, CasinoCard)>();
			}
		}
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, 4.ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 4.ToString());
	}

	public string getAbilityPrompt()
	{
		return "";
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address != base.address)
		{
			return;
		}
		if (_data.Count < 2 || !(_data[1] is CasinoCardAbilityData casinoCardAbilityData) || !(_data[0] is AddressAbilityData addressAbilityData))
		{
			Debug.LogError($"{role} ability data given is not of correct type!");
			return;
		}
		CasinoCardInfo.Suit new_suit = _board.getRolesInPlay()[addressAbilityData.address].getVisualClassification().toSuit();
		if (base.has_bad_info)
		{
			new_suit = new List<CasinoCardInfo.Suit>().addAll((CasinoCardInfo.Suit _s) => _s != new_suit).getRandomElementFromList(random);
		}
		Maybe<CasinoCard> maybe = base.casino_case.replaceCard(casinoCardAbilityData.card_picked, new_suit);
		if (!maybe.is_some)
		{
			Debug.LogError($"{role} failed to replace card? {casinoCardAbilityData.card_picked.info} | Suit Wanted: {new_suit}");
			return;
		}
		base.casino_case.spendChips(4);
		selection = (addressAbilityData.address, maybe.value).maybe();
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (!selection.is_some)
		{
			Debug.LogError($"{role} | Trying to get info string before card is picked!");
			return "";
		}
		return checkTranslationWithReplace(() => englishInfo(selection.value.Item1.ToString(), selection.value.Item2.info.toSymbolString()), () => selection.value.Item1.ToString(), () => selection.value.Item2.info.toSymbolString());
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (selection.is_some && _occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == selection.value.Item1;
		}
		return false;
	}

	private string englishInfo(string _d1, string _d2)
	{
		return "#" + _d1 + "'s card is the " + _d2 + "!";
	}

	public override string getUniqueSaveData()
	{
		if (!selection.is_some)
		{
			return "";
		}
		return $"{selection.value.Item1},{selection.value.Item2.value},{(int)selection.value.Item2.suit}";
	}
}
