using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Devil : CasinoRoleData, IHaveRoleAbility, IHaveAbility
{
	private const int ability_cost = 20;

	private int made_evil = -1;

	private int picked_role = -1;

	public override Roles role => Roles.DEVIL;

	public override string english_name => "Devil";

	public override string english_description => "I make 1 " + TextHelper.goodRole + " " + Alignments.EVIL.toString() + ".\n" + TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.ROLE.toString() + ", I " + Keywords.ANNOUNCE.toString() + " how many " + Keywords.STEPS.toString() + " the chosen " + Keywords.ROLE.toString() + " is from the " + Keywords.ROLE.toString() + " I made " + Alignments.EVIL.toString() + ".\nYou must " + Keywords.ARREST.toString() + " me to use my " + Keywords.ABILITY.toString() + ". " + TextHelper.iLieAndPretendNotInPlay + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)>();

	public override string credits => "gv";

	public bool allowSelfTarget => true;

	public bool abilityExhausted
	{
		get
		{
			if (ability_exhausted && !base.tainted)
			{
				return made_evil > 0;
			}
			return false;
		}
	}

	public int numberTargets => 1;

	public override bool hasInfo
	{
		get
		{
			if (ability_exhausted)
			{
				return picked_role > 0;
			}
			return false;
		}
	}

	public override bool has_truth_hover_focus => made_evil > 0;

	public Devil(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			made_evil = int.Parse(array[0]);
			picked_role = int.Parse(array[0]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			made_evil = -1;
			picked_role = -1;
		}
	}

	public Devil(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, 20.ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 20.ToString());
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(numberTargets);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted || (!base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED) && base.dead))
		{
			return _board;
		}
		RoleData randomElementFromList = _board.getRolesInPlayOfClass(default(RoleClassifications)).getRandomElementFromList(random);
		made_evil = randomElementFromList.getAddress();
		randomElementFromList.setAlignment(Alignments.EVIL);
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address || !base.arrested || base.tainted || base.dead)
		{
			return _board;
		}
		if (_target_addresses.Count == 0)
		{
			Debug.LogError($"{role} ability targets list is empty!");
			return _board;
		}
		picked_role = _target_addresses[0];
		base.casino_case.spendChips(20);
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (base.tainted)
		{
			return _board;
		}
		if (_arrested_address == base.address)
		{
			setDisguise(new Maybe<RoleData>());
			if (abilityExhausted)
			{
				ability_exhausted = false;
			}
		}
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (picked_role == -1)
		{
			Debug.LogError($"No picked role but trying to generation info {role}!");
			return "";
		}
		Dictionary<int, RoleData> address_occupents = _snap.address_occupents;
		int replace = address_occupents[picked_role].getBoardPosition().cardinalDistance(address_occupents[made_evil].getBoardPosition());
		return checkTranslationWithPlural(englishInfo, replace);
	}

	private string englishInfo(string _d1)
	{
		return "You will find what you seek " + _d1 + " step{#/s} away.";
	}

	public override string getTruthString()
	{
		return ((made_evil > 0) ? (TextHelper.madeEvilOneLocalised(made_evil) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == made_evil;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return $"{made_evil},{picked_role}";
	}
}
