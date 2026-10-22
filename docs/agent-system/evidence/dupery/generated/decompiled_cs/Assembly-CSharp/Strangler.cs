using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Strangler : RoleData
{
	private List<int> killed = new List<int>();

	public override Roles role => Roles.STRANGLER;

	public override string english_name => "Strangler";

	public override string english_description => TextHelper.iLieAndPretendSuspected + " with an " + Keywords.ABILITY.toString() + ". I might " + Keywords.KILL.toString() + " any " + Keywords.ROLE.toString() + " you pick with my " + Keywords.ABILITY.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I have a 50% chance to " + Keywords.KILL.toString() + " each " + Keywords.ROLE.toString() + " you pick."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => killed.Count > 0;

	public Strangler(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Strangler(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			killed = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Could not load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			killed = new List<int>();
		}
	}

	protected override bool getEnglishNamePrefixOption()
	{
		return false;
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new SuspectRequireRoleGC((Roles _r) => _r.getClassificationFromRoleType() == RoleClassifications.INNOCENT && _r.createEmptyRole().getHasRoleAbility(), new RequirementEEB(RoleGenerationMarkers.HAS_ABILITY)));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return new DisguiseCharacteristics(DisguiseTarget.CUSTOM_SUSPECTED, new List<RoleClassifications>
		{
			RoleClassifications.INNOCENT,
			RoleClassifications.MEDDLER
		}, (RoleData _r) => _r.getHasRoleAbility(), new List<Roles>());
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		foreach (int _target_address in _target_addresses)
		{
			if (random.Next(0, 2) == 1)
			{
				base.case_ref.killAddress(_target_address, ((RoleData)this).maybe());
				killed.Add(_target_address);
			}
		}
		return _board;
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
