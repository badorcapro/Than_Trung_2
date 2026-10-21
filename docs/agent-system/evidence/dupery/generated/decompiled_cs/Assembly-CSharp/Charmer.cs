using System;
using System.Collections.Generic;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Charmer : RoleData
{
	private List<int> tainted_targets = new List<int>();

	public override Roles role => Roles.CHARMER;

	public override string english_name => "Charmer";

	public override string english_description => "I " + Keywords.TAINT.toString() + " every " + TextHelper.innocentOrMeddlerRole + " that targets me with an " + Keywords.ABILITY.toString() + ". " + TextHelper.iLieAndPretendSuspected;

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "If I am " + TextHelper.tainted + ", " + TextHelper.deadOrArrested + ", I do not " + Keywords.TAINT.toString() + " any " + Keywords.ROLE.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => tainted_targets.Count > 0;

	public Charmer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Charmer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			tainted_targets = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Could not load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			tainted_targets = new List<int>();
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.TAINTS, new InPlayRequireRoleGC((Roles _r) => _r.createEmptyRole().getHasRoleAbility(), new RequirementEEB(RoleGenerationMarkers.HAS_ABILITY), 1, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (base.tainted || base.arrested || base.dead)
		{
			return _board;
		}
		if (!_target_addresses.Contains(base.address))
		{
			return _board;
		}
		RoleData roleData = _board.getRolesInPlay()[_ability_user_address];
		if (!roleData.getVisualClassification().equalToAny(RoleClassifications.INNOCENT, RoleClassifications.MEDDLER))
		{
			return _board;
		}
		roleData.setTainted(_new: true);
		tainted_targets.addIfNotDuplicate(roleData.getAddress());
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return ((tainted_targets.Count > 0) ? (TextHelper.taintedManyLocalised(tainted_targets) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return tainted_targets.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return tainted_targets.toStringCommaSeperated();
	}
}
