using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class PowderMerchant : DocksRoleData
{
	public override Roles role => Roles.POWDER_MERCHANT;

	public override string english_name => "Powder Merchant";

	public override string english_description => "I add a " + LocationTypes.NAVAL_MINE.toString() + " on the " + Keywords.BOARD.toString() + ". I am " + Keywords.SURROUNDING.toString() + " the " + LocationTypes.NAVAL_MINE.toString() + ". A random " + TextHelper.innocentOrMeddlerRole + " that is " + Keywords.CARDINALLY_ADJACENT.toString() + " to the " + LocationTypes.NAVAL_MINE.toString() + " becomes a trap. If the " + Keywords.BOAT.toString() + " is moved on them, the " + LocationTypes.NAVAL_MINE.toString() + " will explode. " + TextHelper.iLieAndPretendSuspected + ".";

	public override bool hasInfo => false;

	public PowderMerchant(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public PowderMerchant(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new List<AdvancedGenerationConstraint>
		{
			new PositionLocationGC(LocationTypes.NAVAL_MINE, GCPosition.SURROUNDING, DisguiseConstraintType.ALWAYS_IGNORE),
			new AddPositionalConstraintToRoleGC(new List<RoleClassifications>
			{
				RoleClassifications.INNOCENT,
				RoleClassifications.MEDDLER
			}, new PositionLocationGC(LocationTypes.NAVAL_MINE, GCPosition.ADJACENT, DisguiseConstraintType.ALWAYS_IGNORE))
		});
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted)
		{
			return _board;
		}
		Dictionary<LocationTypes, LocationData> locationsInPlay = _board.getLocationsInPlay();
		if (!locationsInPlay.ContainsKey(LocationTypes.NAVAL_MINE))
		{
			Debug.LogError($"Could not find the naval mine! {role}");
			return _board;
		}
		NavalMine navalMine = locationsInPlay[LocationTypes.NAVAL_MINE] as NavalMine;
		List<RoleData> adjacentRolesFromGridPos = _board.getAdjacentRolesFromGridPos(navalMine.getBoardPosition(), base.case_ref.board_size);
		adjacentRolesFromGridPos = adjacentRolesFromGridPos.Where((RoleData _r) => _r.getVisualClassification().equalToAny(RoleClassifications.INNOCENT, RoleClassifications.MEDDLER)).ToList();
		if (adjacentRolesFromGridPos.Count == 0)
		{
			Debug.LogError($"{role} could not find a valid role to make as explody guy.");
			return _board;
		}
		navalMine.addExtraTrigger(adjacentRolesFromGridPos.getRandomElementFromList(random).getBoardPosition());
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
