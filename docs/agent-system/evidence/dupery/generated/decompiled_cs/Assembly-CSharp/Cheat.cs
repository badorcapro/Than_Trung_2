using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Cheat : RoleData
{
	public override Roles role => Roles.CHEAT;

	public override string english_name => "Cheat";

	public override string english_description => TextHelper.iLieAndPretendInPlay + ". I add a " + LocationTypes.CARD_SHUFFLER.toString() + " to the " + Keywords.BOARD.toString() + ".";

	public override bool hasInfo => false;

	public Cheat(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Cheat(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new InPlayLocationGC(LocationTypes.CARD_SHUFFLER, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.IN_PLAY);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return "";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address != base.address || base.tainted)
		{
			return _board;
		}
		(_board.getLocationsInPlay()[LocationTypes.CARD_SHUFFLER] as CardShuffler).forceCloseShuffler();
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKillAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		if (_murdered_address != base.address || base.tainted)
		{
			return _board;
		}
		(_board.getLocationsInPlay()[LocationTypes.CARD_SHUFFLER] as CardShuffler).forceCloseShuffler();
		return base.onKillAction(_board, _payload, _murdered_address, _killer);
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
