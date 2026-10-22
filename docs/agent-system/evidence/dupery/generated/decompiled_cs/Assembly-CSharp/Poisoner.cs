using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Poisoner : RoleData
{
	private int target_address = -1;

	public override Roles role => Roles.POISONER;

	public override string english_name => "Poisoner";

	public override string english_description => "I " + Keywords.TAINT.toString() + " a random " + RoleClassifications.INNOCENT.toString() + " " + TextHelper.surroundingNeighbour + ".\n" + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, "When I am " + TextHelper.tainted + " I do not " + Keywords.TAINT.toString() + " my " + Keywords.TARGET.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => target_address != -1;

	public Poisoner(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Poisoner(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		target_address = RoleHelper.tryLoadSingleValueFromUniqueData(role, _save);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.TAINTS);
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
		List<RoleData> list = (from _e in _board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size)
			where _e.getVisualClassification() == RoleClassifications.INNOCENT
			select _e).ToList();
		if (list.Count != 0)
		{
			RoleData randomElementFromList = list.getRandomElementFromList(random);
			randomElementFromList.setTainted(_new: true);
			target_address = randomElementFromList.getAddress();
		}
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return $"{target_address}";
	}
}
