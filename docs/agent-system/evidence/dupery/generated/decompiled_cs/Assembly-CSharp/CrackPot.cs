using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class CrackPot : CasinoRoleData, IHaveSpecialAbility, IHaveAbility
{
	private const int ability_cost = 2;

	private Maybe<CasinoCard> card_picked = new Maybe<CasinoCard>();

	public override Roles role => Roles.CRACKPOT;

	public override string english_name => "Crackpot";

	public override string english_description => TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.CARD.toString() + " and discard it. If the " + Keywords.ROLE.toString() + " at the " + Keywords.ADDRESS.toString() + " equal to the " + TextHelper.cardsValue + " is " + TextHelper.pretending + ", I " + Keywords.REVEAL.toString() + " them. Otherwise, I make them " + Keywords.PRETEND.toString() + " to be a " + TextHelper.tainted + " " + TextHelper.suspectedUnderlingRole + ". No " + Keywords.ROLE.toString() + " can " + Keywords.PRETEND.toString() + " to be me.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "If a " + Keywords.FACE_CARD.toString() + " or any " + Keywords.CARD.toString() + " whose " + TextHelper.value + " is not equal to the " + Keywords.ADDRESS.toString() + " of any " + Keywords.ROLE.toString() + " is picked, I will " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\"."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTaintedMyBehaviourRemains));
			return list;
		}
	}

	public override bool can_be_disguise => false;

	public SpecialAbilityType ability_type => SpecialAbilityType.CARD_ABILITY;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public override bool hasInfo
	{
		get
		{
			if (ability_exhausted)
			{
				return card_picked.is_some;
			}
			return false;
		}
	}

	public CrackPot(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public CrackPot(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			if (_save.unique_data == "")
			{
				card_picked = new Maybe<CasinoCard>();
			}
			string[] array = _save.unique_data.Split(',');
			card_picked = new CasinoCard(new CasinoCardInfo(int.Parse(array[0]), (CasinoCardInfo.Suit)int.Parse(array[1]))).maybe();
		}
		catch (Exception ex)
		{
			Debug.LogError($"Failed to load {ex}!\nSave: {_save.unique_data}\nError: {ex}");
			card_picked = new Maybe<CasinoCard>();
		}
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return defaultFillDescription(_description);
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 2.ToString());
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type == DescriptionType.SPECIAL)
		{
			return _description.Replace(RoleData.loc_marker_1, checkTranslation(englishInfo));
		}
		return base.fillExtraDescription(_description, _type);
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectACardLocalised;
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address != base.address)
		{
			return;
		}
		if (_data.Count < 1 || !(_data[0] is CasinoCardAbilityData casinoCardAbilityData))
		{
			Debug.LogError($"{role} ability data is empty or of wrong type!");
			return;
		}
		card_picked = casinoCardAbilityData.card_picked.maybe();
		base.casino_case.replaceCard(casinoCardAbilityData.card_picked);
		base.casino_case.spendChips(2);
		if (card_picked.value.value > 10)
		{
			return;
		}
		Dictionary<int, RoleData> rolesInPlay = _board.getRolesInPlay();
		if (!rolesInPlay.ContainsKey(card_picked.value.value))
		{
			return;
		}
		RoleData roleData = rolesInPlay[card_picked.value.value];
		if (roleData.getDisguise().is_some)
		{
			roleData.setDisguise(new Maybe<RoleData>());
			return;
		}
		RoleData roleData2 = (from _r in base.case_ref.getSuspectList()
			where _r.isUnderling()
			select _r).ToList().getRandomElementFromList(random).createRole(roleData.getAddress(), roleData.getBoardPosition(), random, roleData.maybe());
		roleData2.setTainted(_new: true);
		roleData.setDisguise(roleData2.maybe());
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (!card_picked.is_some)
		{
			Debug.LogError($"{role} trying to generate info before ability has been used!");
			return "";
		}
		if (card_picked.value.value > 10)
		{
			return checkTranslation(englishInfo);
		}
		if (!_snap.address_occupents.ContainsKey(card_picked.value.value))
		{
			return checkTranslation(englishInfo);
		}
		return "";
	}

	private string englishInfo()
	{
		return "I see no one over there.";
	}

	public override string getUniqueSaveData()
	{
		if (!card_picked.is_some)
		{
			return "";
		}
		return $"{card_picked.value.value},{(int)card_picked.value.suit}";
	}
}
