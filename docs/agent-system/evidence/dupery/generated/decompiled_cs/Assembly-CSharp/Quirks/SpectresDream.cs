using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class SpectresDream : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.SPECTRES_DREAM;

	protected override string english_name => "Spectre's Dream";

	protected override string english_description => "Every " + Keywords.ROLE.toString() + " starts " + TextHelper.obscured + ".";

	public override string credit => "Smile";

	public override bool is_case_start_quirk => true;

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		_board.getRolesInPlay().Values.ToList().ForEach(delegate(RoleData _r)
		{
			_r.setObscured(_new: true);
		});
		return _board;
	}
}
