using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class CruelSeas : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.CRUEL_SEAS;

	protected override string english_name => "Cruel Seas";

	protected override string english_description => "When an " + TextHelper.innocentRole + " is " + TextHelper.dredged + ", they " + TextHelper.die + ".";

	public override bool is_dredged_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.DOCKS;
	}

	public override void onDredgeRole(DocksCase _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, RoleData _dredged, Maybe<RoleData> _dredger, System.Random _rng)
	{
		if (_dredged.getTrueClassification() == RoleClassifications.INNOCENT)
		{
			_case.killAddress(_dredged.getAddress(), new Maybe<RoleData>());
		}
	}
}
