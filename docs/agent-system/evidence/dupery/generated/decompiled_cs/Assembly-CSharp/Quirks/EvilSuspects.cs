using System;
using System.Collections.Generic;
using GRGLib.Extensions;

namespace Quirks;

public class EvilSuspects : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.EVIL_SUSPECTS;

	protected override string english_name => "Evil Suspects";

	protected override string english_description => "Your " + Keywords.SUSPECT_LIST.toString() + " starts with only " + RoleClassifications.UNDERLING.toString() + " and " + TextHelper.traitorRoles + ".";

	protected override string english_extra_description => "The " + Keywords.SUSPECT_LIST.toString() + " will grow as you " + Keywords.INVESTIGATE.toString() + " new " + TextHelper.roles + ".";

	public override bool is_visual_suspect_list_quirk => true;

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (!_in_play_quirks.Contains(CaseQuirks.PERFECT_CRIME))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override HashSet<RoleData> onVisualSuspectListCreation(HashSet<RoleData> _visual, HashSet<RoleData> _real, Random _rng)
	{
		_visual.RemoveWhere((RoleData _r) => !_r.role.getClassificationFromRoleType().equalToAny(RoleClassifications.UNDERLING, RoleClassifications.TRAITOR));
		return _visual;
	}
}
