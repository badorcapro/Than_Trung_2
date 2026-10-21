using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class VIP : CasinoRoleData
{
	private List<int> tainted_targets = new List<int>();

	public override Roles role => Roles.VIP;

	public override string english_name => "VIP";

	public override string english_description => "I " + Keywords.TAINT.toString() + " all " + TextHelper.innocentRoles + " that have an " + Keywords.ADDRESS.toString() + " equal to one of your starting " + TextHelper.cardsValues + ". " + TextHelper.iLieAndPretendNotInPlay + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, TextHelper.faceCards_cap + " have no " + TextHelper.value + " and point to no " + TextHelper.addresses + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not " + Keywords.TAINT.toString() + " any " + Keywords.ROLE.toString() + "."));
			return list;
		}
	}

	public override string credits => "5kBird";

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => true;

	public VIP(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public VIP(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.TAINTS);
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return "";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted)
		{
			return _board;
		}
		Dictionary<int, RoleData> rolesInPlay = _board.getRolesInPlay();
		if (base.casino_case.left_card.value <= 10)
		{
			checkTaintRole(rolesInPlay.tryGet(base.casino_case.left_card.value));
		}
		if (base.casino_case.right_card.value <= 10)
		{
			checkTaintRole(rolesInPlay.tryGet(base.casino_case.right_card.value));
		}
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	private void checkTaintRole(Maybe<RoleData> _role)
	{
		if (_role.is_some && _role.value.getVisualClassification() == RoleClassifications.INNOCENT)
		{
			_role.value.setTainted(_new: true);
			tainted_targets.Add(_role.value.getAddress());
		}
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
