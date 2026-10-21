using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class MistyStreets : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.MISTY_STREETS;

	protected override string english_name => "Misty Streets";

	protected override string english_description => "Each case starts with an " + TextHelper.obscured + " " + Keywords.ROLE.toString() + ".";

	public override bool is_case_start_quirk => true;

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		_board.getRolesInPlay().Values.ToList().getRandomElementFromList(_rng).setObscured(_new: true);
		return _board;
	}
}
