using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Leads;

namespace Save;

[Serializable]
public class LeadProgressionManagerCustomSave
{
	public Regions region;

	public string custom_override;

	public Maybe<List<CaseQuirks>> available_quirks;

	public LeadProgressionManagerCustomSave(LeadProgressionManager _manager)
	{
		region = _manager.region;
		custom_override = _manager.getOverrideSaveData();
		available_quirks = (_manager.available_quirks.is_some ? _manager.available_quirks.value.copy().maybe() : new Maybe<List<CaseQuirks>>());
	}
}
