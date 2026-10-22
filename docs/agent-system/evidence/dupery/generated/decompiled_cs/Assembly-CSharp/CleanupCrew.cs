using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class CleanupCrew : RoleData
{
	public override Roles role => Roles.CLEANUP_CREW;

	public override string english_name => "Cleanup Crew";

	public override string english_description => "I hide the " + LocationTypes.CRIME_SCENE.toString() + " as a " + LocationTypes.BLOOD_TRACE.toString() + ". I add a " + LocationTypes.BLOOD_TRACE.toString() + " to the " + Keywords.BOARD.toString() + ". " + TextHelper.iLieAndPretendSuspected + ".";

	public override bool hasInfo => false;

	public CleanupCrew(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public CleanupCrew(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new InPlayLocationGC(LocationTypes.BLOOD_TRACE, DisguiseConstraintType.ALWAYS_IGNORE));
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
		return base.getTruthString();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted)
		{
			return _board;
		}
		_board.getLocationsInPlay()[LocationTypes.CRIME_SCENE].setDisguise(LocationTypes.BLOOD_TRACE);
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
