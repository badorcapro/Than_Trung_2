using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using GameStats;

namespace Save;

[Serializable]
public class StatsSaveData
{
	public Regions region;

	public bool run_won;

	public List<LeadStatsSaveData> lead_stats;

	public Maybe<LeadStatsSaveData> current_stats;

	public StatsSaveData(RunStats _stats)
	{
		region = _stats.run_region;
		run_won = _stats.run_won;
		lead_stats = _stats.lead_stats.Select((LeadStats _l) => new LeadStatsSaveData(_l)).ToList();
		current_stats = _stats.current_lead.fmap((LeadStats _s) => new LeadStatsSaveData(_s));
	}

	public StatsSaveData()
	{
	}
}
