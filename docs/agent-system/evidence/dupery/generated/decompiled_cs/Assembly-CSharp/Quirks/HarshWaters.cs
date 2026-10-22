using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class HarshWaters : CaseQuirkData
{
	private const int fuel_cost = 1;

	public override CaseQuirks quirk_type => CaseQuirks.HARSH_WATERS;

	protected override string english_name => "Rocky Shallows";

	protected override string english_description => string.Format("{0} a {1} now costs {2} {3}.", "Dredging".asKeyword(Keywords.DREDGE), Keywords.ROLE.toString(), 1, Keywords.FUEL.toString());

	public override bool is_dredged_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.DOCKS;
	}

	public override void onDredgeRole(DocksCase _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, RoleData _dredged, Maybe<RoleData> _dredger, System.Random _rng)
	{
		_case.loseFuel(1);
	}
}
