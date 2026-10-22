using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Offeror : CasinoRoleData, IHaveRoleAbility, IHaveAbility
{
	private const int ability_cost = 8;

	private int ability_target = -1;

	private Maybe<Alignments> ability_result = new Maybe<Alignments>();

	public override Roles role => Roles.OFFEROR;

	public override string english_name => "Fixer";

	public override string english_description => TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.ROLE.toString() + ". If they are an " + RoleClassifications.UNDERLING.toString() + ", I make them " + Alignments.GOOD.toString() + ". Otherwise I make them " + Alignments.EVIL.toString() + ". " + TextHelper.otherRolesCannotPretendToBeMe;

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not change the " + Keywords.ALIGNMENT.toString() + " of the picked " + Keywords.ROLE.toString() + "."));
			return list;
		}
	}

	public override bool can_be_disguise => false;

	public bool allowSelfTarget => true;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public override bool hasInfo => ability_target != -1;

	public override bool has_hover_focus => hasInfo;

	public override bool has_truth_hover_focus => ability_result.is_some;

	public Offeror(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Offeror(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			ability_target = int.Parse(array[0]);
			ability_result = ((array[1] == "f") ? new Maybe<Alignments>() : ((Alignments)int.Parse(array[1])).maybe());
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			ability_target = -1;
			ability_result = new Maybe<Alignments>();
		}
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 8.ToString());
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return defaultFillDescription(_description);
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(1);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		if (_target_addresses.Count == 0)
		{
			Debug.LogError($"{role} ability used without any roles selected!");
			return _board;
		}
		ability_target = _target_addresses[0];
		base.casino_case.spendChips(8);
		if (base.tainted)
		{
			return _board;
		}
		RoleData roleData = _board.getRolesInPlay()[ability_target];
		if (roleData.getVisualClassification() == RoleClassifications.UNDERLING)
		{
			roleData.setAlignment(Alignments.GOOD);
			ability_result = Alignments.GOOD.maybe();
		}
		else
		{
			roleData.setAlignment(Alignments.EVIL);
			ability_result = Alignments.EVIL.maybe();
		}
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (ability_target == -1)
		{
			Debug.LogError($"Trying to generate info before ability has been used! {role}");
			return "";
		}
		return checkTranslationWithData(englishInfo, ability_target);
	}

	private string englishInfo(string _d1)
	{
		return "#" + _d1 + " has accepted the job.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == ability_target;
		}
		return false;
	}

	public override string getTruthString()
	{
		if (!ability_result.is_some)
		{
			return base.getTruthString();
		}
		string text = ((ability_result.value != Alignments.EVIL) ? TextHelper.madeGoodOneLocalised(ability_target) : TextHelper.madeEvilOneLocalised(ability_target));
		string truthString = base.getTruthString();
		return text + ((truthString == "") ? "" : ("\n" + truthString));
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == ability_target;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return string.Format("{0},{1}", ability_target, ability_result.is_some ? ((int)ability_result.value).ToString() : "f");
	}
}
