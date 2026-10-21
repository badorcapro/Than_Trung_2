using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class NightShift : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.NIGHT_SHIFT;

	protected override string english_name => "Night Shift";

	protected override string english_description => "A random non-" + TextHelper.innocentRole + " starts " + TextHelper.hidden + " each " + Keywords.CASE.toString() + ".";

	public override bool is_case_start_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.DOCKS;
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		if (!(_case is DocksCase))
		{
			Debug.LogError($"{quirk_type} is a docks quirk but found in a {_case.case_type} case!");
			return _board;
		}
		_board.getRolesInPlayOfClass(RoleClassifications.MEDDLER, RoleClassifications.UNDERLING, RoleClassifications.TRAITOR).getRandomElementFromList(_rng).setHidden(_new: true);
		return _board;
	}
}
