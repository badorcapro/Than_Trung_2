using System;
using System.Collections.Generic;
using GRGLib.Extensions;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class ViolentHost : CasinoRoleData
{
	private const int kill_cost = 10;

	private List<int> killed = new List<int>();

	public override Roles role => Roles.VIOLENT_HOST;

	public override string english_name => "Violent Host";

	public override string english_description => "When a " + Keywords.CARD.toString() + " is discarded, I might " + Keywords.KILL.toString() + " the " + Keywords.ROLE.toString() + " at the " + TextHelper.cardsValue + " " + Keywords.ADDRESS.toString() + ". " + $"Every {Keywords.KILL.toString()} I make will cost you {10} {TextHelper.chips_with_link}. {TextHelper.iLieAndPretendNotInPlay}.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I have a 50% chance to " + Keywords.KILL.toString() + " when a " + Keywords.CARD.toString() + " is discarded but I never " + Keywords.KILL.toString() + " " + TextHelper.underlingOrTraitorRoles + "."));
			list.Add((DescriptionType.SPECIAL, "Jack, Queen and King " + TextHelper.cards + " have no " + Keywords.CARD_VALUE.toString() + " so I will never " + Keywords.KILL.toString() + " when one is discarded."));
			return list;
		}
	}

	public override string credits => "ExistingHuman";

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => killed.Count > 0;

	public ViolentHost(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			killed = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Problem loading role {role}! ({_save.unique_data}) Error: {arg}");
			killed = new List<int>();
		}
	}

	public ViolentHost(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCardDrawnAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload, List<CasinoCard> _discarded, List<CasinoCard> _new_cards)
	{
		if (base.tainted || ((base.arrested || base.dead) && !base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED)))
		{
			return _board;
		}
		foreach (CasinoCard item in _discarded)
		{
			int value = item.value;
			Dictionary<int, RoleData> rolesInPlay = _board.getRolesInPlay();
			if (value <= 10 && rolesInPlay.ContainsKey(value) && !rolesInPlay[value].getIsDead() && !rolesInPlay[value].getVisualClassification().equalToAny(RoleClassifications.UNDERLING, RoleClassifications.TRAITOR) && random.Next(0, 2) == 1)
			{
				base.casino_case.killAddress(value, ((RoleData)this).maybe());
				base.casino_case.spendChips(10);
			}
		}
		return base.onCardDrawnAction(_board, _payload, _discarded, _new_cards);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return ((killed.Count > 0) ? (TextHelper.killedManyLocalised(killed) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return killed.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
