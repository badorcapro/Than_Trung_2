using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Detractor : RoleData
{
	private int target_address = -1;

	public override Roles role => Roles.DETRACTOR;

	public override string english_name => "Detractor";

	public override string english_description => "If you have " + TextHelper.excellentReputation + " at the start of the case, I " + Keywords.TAINT.toString() + " an " + TextHelper.innocentRole + " I am not " + Keywords.CARDINALLY_ADJACENT.toString() + " to. If you have " + TextHelper.goodReputation + " at the start of the case, I " + Keywords.TAINT.toString() + " an " + Keywords.CARDINALLY_ADJACENT.toString() + " " + TextHelper.innocentRole + ". " + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "If you have " + TextHelper.poorReputation + " at the start of the case, I " + Keywords.TAINT.toString() + " no one."));
			list.Add((DescriptionType.SPECIAL, "I am always " + Keywords.CARDINALLY_ADJACENT.toString() + " to at least 1 " + TextHelper.innocentRole + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, "When I am " + TextHelper.tainted + " I " + Keywords.TAINT.toString() + " no one."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => target_address != -1;

	public Detractor(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Detractor(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		target_address = RoleHelper.tryLoadSingleValueFromUniqueData(role, _save);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.TAINTS, new List<AdvancedGenerationConstraint>
		{
			new PositionRoleGC(RoleClassifications.INNOCENT, GCPosition.ADJACENT, DisguiseConstraintType.ALWAYS_IGNORE),
			new PositionRoleGC(RoleClassifications.INNOCENT, GCPosition.NOT_ADJACENT, DisguiseConstraintType.ALWAYS_IGNORE)
		});
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return ((target_address == -1) ? "" : (TextHelper.taintedOneLocalised(target_address) + "\n")) + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == target_address;
		}
		return false;
	}

	public override List<RevealLineSettings> getRevealLines(CaseSnapshot _snap)
	{
		if (target_address != -1)
		{
			return getRevealLineToTarget(target_address, RevealLineColour.PURPLE, _snap);
		}
		return new List<RevealLineSettings>();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted)
		{
			return _board;
		}
		List<RoleData> list;
		switch (CaseHelper.getVisualReputationStatus(base.case_ref))
		{
		case ReputationStatus.EXCEPTIONAL:
			list = (from _r in _board.getNonAdjacentRolesFromGridPos(base.board_position)
				where _r.getVisualClassification() == RoleClassifications.INNOCENT
				select _r).ToList();
			break;
		case ReputationStatus.NEUTRAL:
			list = (from _r in _board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size)
				where _r.getVisualClassification() == RoleClassifications.INNOCENT
				select _r).ToList();
			break;
		default:
			return _board;
		}
		if (list.Count == 0)
		{
			return _board;
		}
		RoleData randomElementFromList = list.getRandomElementFromList(random);
		randomElementFromList.setTainted(_new: true);
		target_address = randomElementFromList.getAddress();
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return $"{target_address}";
	}
}
