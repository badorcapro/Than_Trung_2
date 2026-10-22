using System.Collections.Generic;
using System.Linq;

namespace Quirks;

public class Haunted : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.HAUNTED;

	protected override string english_name => "Haunted";

	protected override string english_description => TextHelper.traitors + " function while " + TextHelper.deadOrArrested + ".";

	public override bool is_marker_quirk => true;

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (_available_roles.Any((Roles _r) => _r.getClassificationFromRoleType() == RoleClassifications.TRAITOR))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}
}
