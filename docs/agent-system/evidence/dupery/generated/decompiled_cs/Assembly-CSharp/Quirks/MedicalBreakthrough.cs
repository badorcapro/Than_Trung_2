using System.Collections.Generic;
using Leads;

namespace Quirks;

public class MedicalBreakthrough : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.MEDICAL_BREAKTHROUGH;

	protected override string english_name => "Medical Breakthrough";

	protected override string english_description => "The " + Roles.SURGIN.toString() + " will always " + Keywords.KILL.toString() + " when they are not " + TextHelper.lyingOrTainted + ".";

	public override bool is_marker_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CLOCK;
	}

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (_available_roles.Contains(Roles.SURGIN))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return canRoleAppearInPlay(Roles.SURGIN, _unforced, _forced);
	}
}
