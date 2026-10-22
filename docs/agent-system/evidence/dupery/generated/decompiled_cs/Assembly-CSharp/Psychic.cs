using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Psychic : CasinoRoleData, IHaveMultiAbility, IHaveSpecialAbility, IHaveAbility
{
	public class PsychicCardAbility : IHaveSpecialAbility, IHaveAbility
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

	public class PsychicRoleAbility : IHaveRoleAbility, IHaveAbility
	{
		public bool allowSelfTarget => true;

		public bool abilityExhausted => false;

		public int numberTargets => 2;

		public string getAbilityPrompt()
		{
			return TextHelper.ab_selectRolesLocalised(numberTargets);
		}

		public bool validateTarget(RoleData _roll_candidate)
		{
			return true;
		}
	}

	private const int ability_cost = 6;

	private const int nb_roles_to_pick = 2;

	private Maybe<(int, int, CasinoCard)> selection = new Maybe<(int, int, CasinoCard)>();

	public override Roles role => Roles.PSYCHIC;

	public override string english_name => "Psychic";

	public override string english_description => $"{TextHelper.ability_with_cost_marker}: Pick a {Keywords.CARD.toString()} and {2} {TextHelper.roles}. Discard the {Keywords.CARD.toString()}. I {Keywords.ANNOUNCE.toString()} how many {TextHelper.roles} picked " + "are of the " + Keywords.CLASSIFICATION.toString() + " " + TextHelper.associated + " with the " + TextHelper.suit + " of the picked " + Keywords.CARD.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounce + " a random number that is incorrect.") };

	public SpecialAbilityType ability_type => SpecialAbilityType.NONE;

	public List<IHaveAbility> abilities => new List<IHaveAbility>
	{
		new PsychicCardAbility(),
		new PsychicRoleAbility()
	};

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 0;

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

	public Psychic(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Psychic(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		if (_save.unique_data != "")
		{
			try
			{
				string[] array = _save.unique_data.Split(',');
				int item = int.Parse(array[0]);
				int item2 = int.Parse(array[1]);
				int val = int.Parse(array[2]);
				CasinoCardInfo.Suit suit = (CasinoCardInfo.Suit)int.Parse(array[3]);
				selection = (item, item2, new CasinoCard(new CasinoCardInfo(val, suit))).maybe();
			}
			catch (Exception arg)
			{
				Debug.LogError($"Could not parse the save data ({role} | '{_save.unique_data}')!\nError: {arg}");
				selection = new Maybe<(int, int, CasinoCard)>();
			}
		}
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, 6.ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 6.ToString());
	}

	public string getAbilityPrompt()
	{
		return "";
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address == base.address)
		{
			if (_data.Count < 3 || !(_data[0] is CasinoCardAbilityData casinoCardAbilityData) || !(_data[1] is AddressAbilityData addressAbilityData) || !(_data[2] is AddressAbilityData addressAbilityData2))
			{
				Debug.LogError($"{role} ability data given is not of correct type!");
				return;
			}
			base.casino_case.replaceCard(casinoCardAbilityData.card_picked);
			base.casino_case.spendChips(6);
			selection = (addressAbilityData.address, addressAbilityData2.address, casinoCardAbilityData.card_picked).maybe();
		}
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (!selection.is_some)
		{
			Debug.LogError($"{role} | Trying to get info string before selection is picked!");
			return "";
		}
		Dictionary<int, RoleData> address_occupents = _snap.address_occupents;
		RoleClassifications roleClassifications = selection.value.Item3.suit.toClass();
		int num = ((address_occupents[selection.value.Item1].getVisualClassification() == roleClassifications) ? 1 : 0) + ((address_occupents[selection.value.Item2].getVisualClassification() == roleClassifications) ? 1 : 0);
		if (!base.has_bad_info)
		{
			return getInfo(num, roleClassifications);
		}
		int num2 = random.Next(0, 3);
		if (num2 == num)
		{
			num2 = (num2 + 1) % 3;
		}
		return getInfo(num2, roleClassifications);
	}

	private string getInfo(int _nb, RoleClassifications _class)
	{
		return LocalisationHelper.checkPlural(checkTranslationWithReplace(() => englishInfo(_nb.ToString(), _class.toString()), () => _nb.ToString(), () => _class.toString()), _nb);
	}

	private string englishInfo(string _d1, string _d2)
	{
		return "I see " + _d1 + " " + _d2 + " role{#/s}!";
	}

	public override string getUniqueSaveData()
	{
		if (!selection.is_some)
		{
			return "";
		}
		return $"{selection.value.Item1},{selection.value.Item2},{selection.value.Item3.value},{(int)selection.value.Item3.suit}";
	}
}
