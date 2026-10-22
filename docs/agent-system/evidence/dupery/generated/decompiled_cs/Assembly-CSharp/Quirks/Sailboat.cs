using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class Sailboat : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.SAILBOAT;

	protected override string english_name => "Sailboat";

	protected override string english_description => "Moving the " + Keywords.BOAT.toString() + " 2 or more " + Keywords.STEPS.toString() + " costs 1 less " + Keywords.FUEL.toString() + ".";

	public override bool is_case_start_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.DOCKS;
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		if (!(_case is DocksCase docksCase))
		{
			Debug.LogError($"{quirk_type} is a docks exclusive quirk but found in a {_case.case_type} case!");
			return _board;
		}
		docksCase.doBoatConstructorAction(delegate(DocksBoat _b)
		{
			_b.fuel_cost_changes.Add((DocksBoat _b, Vector2Int _p) => (_p.cardinalDistance(_b.position) > 1) ? (-1) : 0);
		});
		return _board;
	}
}
