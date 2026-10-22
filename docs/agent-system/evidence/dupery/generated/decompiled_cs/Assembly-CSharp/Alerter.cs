using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Alerter : RoleData, IHaveSpecialAbility, IHaveAbility
{
	private Maybe<LocationTypes> ability_result = new Maybe<LocationTypes>();

	public override Roles role => Roles.ALERTER;

	public override string english_name => "Alerter";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick a " + Keywords.LOCATION.toString() + ". I " + Keywords.ANNOUNCE.toString() + " how many " + TextHelper.evilRoles + " are " + Keywords.CARDINALLY_ADJACENT.toString() + " to it.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounce + " a random number between 0 and 4 that is incorrect.") };

	public override string credits => "lucas simple";

	public override bool hasInfo => abilityExhausted;

	public SpecialAbilityType ability_type => SpecialAbilityType.LOCATION;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public override bool has_hover_focus => ability_result.is_some;

	public Alerter(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Alerter(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		ability_result = RoleHelper.tryLoadSimpleMaybeFromUniqueData(role, _save, (int _i) => (LocationTypes)_i);
	}

	protected override bool getEnglishNamePrefixOption()
	{
		return false;
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectALocationLocalised;
	}

	public void onSpecialAbility(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _user_address, List<AbilityData> _data)
	{
		if (_user_address == base.address)
		{
			if (_data.Count == 0 || !(_data[0] is LocationAbilityData locationAbilityData))
			{
				Debug.LogError($"{role} ability data was empty or not of the correct type!");
			}
			else
			{
				ability_result = locationAbilityData.location.maybe();
			}
		}
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (!ability_result.is_some)
		{
			Debug.LogError($"{role} trying to generate info string before ability has been used.");
			return "";
		}
		LocationData locationData = _snap.board.getLocationsInPlay()[ability_result.value];
		List<RoleData> adjacentRolesFromGridPos = _snap.board.getAdjacentRolesFromGridPos(locationData.getBoardPosition(), base.case_ref.board_size);
		int num = adjacentRolesFromGridPos.Count((RoleData _r) => _r.getVisualAlignment() == Alignments.EVIL);
		if (base.has_bad_info)
		{
			if (adjacentRolesFromGridPos.Count == 0)
			{
				return info(random.Next(1, 5), locationData);
			}
			int num2 = random.Next(0, adjacentRolesFromGridPos.Count + 1);
			if (num2 == num)
			{
				num2 = (num2 + 1) % (adjacentRolesFromGridPos.Count + 1);
			}
			return info(num2, locationData);
		}
		return info(num, locationData);
	}

	private string info(int _nb, LocationData _loc)
	{
		return LocalisationHelper.checkPlural(checkTranslationWithReplace(() => englishInfo(_nb.ToString(), _loc.name), () => _nb.ToString(), () => _loc.name), _nb);
	}

	private string englishInfo(string _d1, string _d2)
	{
		return "There {#is/are} " + _d1 + " evil{#/s} beside the " + _d2 + ".";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return _snap.board.getLocationsInPlay()[ability_result.value].getBoardPosition().cardinalDistance(_position) <= 1;
	}

	public override string getUniqueSaveData()
	{
		return RoleHelper.saveSimpleMaybe(ability_result, (LocationTypes _l) => (int)_l);
	}
}
