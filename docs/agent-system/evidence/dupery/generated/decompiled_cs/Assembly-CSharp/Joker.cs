using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Joker : CasinoRoleData
{
	public override Roles role => Roles.JOKER_R;

	public override string english_name => "Joker";

	public override string english_description => "I replace one of your " + TextHelper.cards + " with a " + Keywords.JOKER.toString() + ". " + TextHelper.iLieAndPretendSuspected + ".";

	public override bool hasInfo => false;

	public Joker(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Joker(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
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
		if (!(_payload is CasinoCaseActionPayload casinoCaseActionPayload))
		{
			Debug.LogError("Joker can only be found in the casino region!");
			return _board;
		}
		if (random.Next(0, 2) == 1)
		{
			casinoCaseActionPayload.left_card.smudged = true;
		}
		else
		{
			casinoCaseActionPayload.right_card.smudged = true;
		}
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.EVIL;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.UNDERLING;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
