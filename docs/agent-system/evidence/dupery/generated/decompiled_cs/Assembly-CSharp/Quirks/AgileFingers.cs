using System.Collections.Generic;

namespace Quirks;

public class AgileFingers : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.AGILE_FINGERS;

	protected override string english_name => "Agile Fingers";

	protected override string english_description => "The " + Roles.PICKPOCKET.toString() + " will now always steal.";

	public override string credit => "gv";

	public override bool is_marker_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CASINO;
	}

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (isCompatible(_case_type))
		{
			return _available_roles.Contains(Roles.PICKPOCKET);
		}
		return false;
	}
}
