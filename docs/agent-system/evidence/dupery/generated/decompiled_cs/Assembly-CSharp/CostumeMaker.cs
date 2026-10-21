using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class CostumeMaker : RoleData
{
	public List<int> targets = new List<int>();

	public override Roles role => Roles.COSTUME_MAKER;

	public override string english_name => "Costume Maker";

	public override string english_description => "I force an " + Keywords.CARDINALLY_ADJACENT.toString() + " " + TextHelper.innocentRole + " to " + Keywords.PRETEND.toString() + " to be an " + TextHelper.notInPlayRole + ". I force a " + Keywords.SURROUNDING.toString() + " " + TextHelper.innocentRole + " to " + Keywords.PRETEND.toString() + " to be a " + TextHelper.inPlayInnocentRole + ". " + TextHelper.iLieAndPretendNotInPlay + ".";

	public override string credits => "gv";

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => true;

	public CostumeMaker(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public CostumeMaker(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			targets = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}! ({_save.unique_data})\nError: {arg}");
			targets = new List<int>();
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new List<AdvancedGenerationConstraint>
		{
			new PositionRoleGC(RoleClassifications.INNOCENT, GCPosition.ADJACENT, DisguiseConstraintType.ALWAYS_IGNORE),
			new PositionRoleGC(RoleClassifications.INNOCENT, GCPosition.SURROUNDING, DisguiseConstraintType.ALWAYS_IGNORE, 2)
		});
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getTruthString()
	{
		return ((targets.Count > 0) ? checkTranslationWithData(base.loc_default_truth_key, getTruthEnglish, CaseHelper.getSimpleMultiAddress(targets)) : "") + "\n" + base.getTruthString();
	}

	private string getTruthEnglish(string _data)
	{
		return "I made " + _data + " pretend to be other roles!";
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return targets.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted)
		{
			return _board;
		}
		List<RoleData> adjacentRolesFromGridPos = _board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size);
		if (adjacentRolesFromGridPos.Count == 0)
		{
			Debug.LogError($"{role}: No adjacent roles?");
			return _board;
		}
		List<RoleData> surroundingRolesFromGridPos = _board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size);
		RoleData randomElementFromList = adjacentRolesFromGridPos.getRandomElementFromList(random);
		randomElementFromList.setDisguise(randomElementFromList.createDisguise(CaseHelper.getInnocentDisguise(DisguiseTarget.NOT_IN_PLAY), _board, _suspects));
		targets.Add(randomElementFromList.getAddress());
		surroundingRolesFromGridPos.Remove(randomElementFromList);
		if (surroundingRolesFromGridPos.Count != 0)
		{
			RoleData randomElementFromList2 = surroundingRolesFromGridPos.getRandomElementFromList(random);
			randomElementFromList2.setDisguise(randomElementFromList2.createDisguise(CaseHelper.getInnocentDisguise(DisguiseTarget.IN_PLAY), _board, _suspects));
			targets.Add(randomElementFromList2.getAddress());
			targets.Sort();
		}
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return targets.toStringCommaSeperated();
	}
}
