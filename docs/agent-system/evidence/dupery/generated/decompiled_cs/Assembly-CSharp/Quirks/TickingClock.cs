using System;

namespace Quirks;

public class TickingClock : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.TICKING_CLOCK;

	protected override string english_name => "Ticking Clock";

	protected override string english_description => "You lose 4 " + Keywords.REPUTATION.toString() + " if you reach the 24th hour without solving the case.";

	public override bool is_time_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		if (_case_type == CaseType.CLOCK)
		{
			return true;
		}
		return false;
	}

	public TickingClock(bool _completed)
	{
		base.quirk_completed = _completed;
	}

	public override void onTime(ClockCase _case, int _current_time, Random _rng)
	{
		if (_current_time >= 24 && !base.quirk_completed && !_case.checkForSolvedCase())
		{
			_case.addReputation(-4);
			base.quirk_completed = true;
		}
	}
}
