using System;
using System.Collections.Generic;

namespace Quirks;

public class PerfectCrime : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.PERFECT_CRIME;

	protected override string english_name => "Perfect Crime";

	protected override string english_description => "Your " + Keywords.SUSPECT_LIST.toString() + " starts empty.";

	protected override string english_extra_description => "The " + Keywords.SUSPECT_LIST.toString() + " will grow as you " + Keywords.INVESTIGATE.toString() + " new " + TextHelper.roles + ".";

	public override bool is_visual_suspect_list_quirk => true;

	public override HashSet<RoleData> onVisualSuspectListCreation(HashSet<RoleData> _visual, HashSet<RoleData> _real, Random _rng)
	{
		return new HashSet<RoleData>();
	}
}
