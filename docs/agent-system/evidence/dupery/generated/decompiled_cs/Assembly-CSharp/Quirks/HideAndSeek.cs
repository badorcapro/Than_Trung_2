using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class HideAndSeek : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.HIDE_AND_SEEK;

	protected override string english_name => "Hide And Seek";

	protected override string english_description => "Every " + Keywords.ROLE.toString() + " starts " + TextHelper.hidden + " except for the " + Roles.CRABER.toString() + ".";

	public override bool is_case_start_quirk => true;

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		_board.getRolesInPlay().Values.ToList().ForEach(delegate(RoleData _r)
		{
			if (_r.role != Roles.CRABER)
			{
				_r.setHidden(_new: true);
			}
		});
		return _board;
	}
}
