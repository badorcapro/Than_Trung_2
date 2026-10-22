using System;
using System.Collections.Generic;
using Leads;

namespace AlternateModes;

public interface IChangeEvents
{
	List<LeadEvent> getCustomEvent(LeadProgressionManager _progression, int _case_nb, Lead _lead, Random _rng);
}
