using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Enforcer : RoleData
{
	private List<int> killed_targets = new List<int>();

	public override Roles role => Roles.ENFORCER;

	public override string english_name => "Enforcer";

	public override string english_description => "The first time a " + Keywords.SURROUNDING.toString() + " " + TextHelper.innocentRole + " uses an " + Keywords.ABILITY.toString() + ", I " + Keywords.KILL.toString() + " them. " + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I am always " + Keywords.SURROUNDING.toString() + " at least 1 " + RoleClassifications.INNOCENT.toString() + " " + Keywords.ABILITY.toString() + " " + Keywords.ROLE.toString() + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, "If I am " + TextHelper.tainted + ", I do not " + Keywords.KILL.toString() + " any " + Keywords.ROLE.toString() + "."));
			return list;
		}
	}

	public override string credits => "Grate";

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => killed_targets.Count > 0;

	public Enforcer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Enforcer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			killed_targets = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Could not load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			killed_targets = new List<int>();
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new PositionRoleGC(RoleClassifications.INNOCENT, RoleGenerationMarkers.HAS_ABILITY, GCPosition.SURROUNDING, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (base.tainted || base.arrested || base.dead || killed_targets.Count > 0)
		{
			return _board;
		}
		if (_board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size).Any((RoleData _r) => _r.getAddress() == _ability_user_address && _r.getVisualClassification() == RoleClassifications.INNOCENT))
		{
			base.case_ref.killAddress(_ability_user_address, this);
			killed_targets.Add(_ability_user_address);
		}
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return ((killed_targets.Count > 0) ? (TextHelper.killedManyLocalised(killed_targets) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return killed_targets.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return killed_targets.toStringCommaSeperated();
	}
}
