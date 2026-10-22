using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class SilentAccomplice : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.SILENT_ACCOMPLICE;

	protected override string english_name => "Silent Accomplice";

	protected override string english_description => "One " + RoleClassifications.INNOCENT.toString() + " becomes " + Alignments.EVIL.toString() + ".";

	public override bool is_case_start_quirk => true;

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		_board.getRolesInPlayOfClass(default(RoleClassifications)).getRandomElementFromList(_rng).setAlignment(Alignments.EVIL);
		return _board;
	}
}
