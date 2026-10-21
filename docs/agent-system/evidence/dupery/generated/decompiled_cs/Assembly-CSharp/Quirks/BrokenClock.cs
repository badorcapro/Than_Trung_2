using System;
using UnityEngine;

namespace Quirks;

public class BrokenClock : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.BROKEN_CLOCK;

	protected override string english_name => "Broken Clock";

	protected override string english_description => "Time passed always incorrectly reads as 0.";

	public override bool is_snapshot_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		if (_case_type == CaseType.CLOCK)
		{
			return true;
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
		clockCaseSnapshot.changeVisualHoursPassed(0);
		return clockCaseSnapshot;
	}
}
