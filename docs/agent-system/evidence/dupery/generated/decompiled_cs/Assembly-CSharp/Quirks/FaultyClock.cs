using System;
using System.Collections.Generic;
using System.Linq;
using Leads;
using UnityEngine;

namespace Quirks;

public class FaultyClock : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.FAULTY_CLOCK;

	protected override string english_name => "Faulty Clock";

	protected override string english_description => "Time on the clock is always offset by a value between -2 and 2.";

	public override bool is_snapshot_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		if (_case_type == CaseType.CLOCK)
		{
			return true;
		}
		return false;
	}

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (!_in_play_quirks.Contains(CaseQuirks.BROKEN_CLOCK))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override CaseSnapshot onSnapshot(Case _case, CaseSnapshot _snap, System.Random _rng)
	{
		if (!(_snap is ClockCaseSnapshot clockCaseSnapshot))
		{
			Debug.LogError($"Snapshot provided is not a clock snapshot! This is not allowed for quirk {quirk_type}");
			return _snap;
		}
		if (!_case.active_quirks.Any((CaseQuirkData _q) => _q.quirk_type == CaseQuirks.BROKEN_CLOCK))
		{
			clockCaseSnapshot.changeVisualHoursPassed(clockCaseSnapshot.visual_hours_passed + _rng.Next(1, 3) * ((_rng.Next(0, 2) != 1) ? 1 : (-1)));
		}
		return clockCaseSnapshot;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return !_quirks.Contains(CaseQuirks.BROKEN_CLOCK);
	}
}
