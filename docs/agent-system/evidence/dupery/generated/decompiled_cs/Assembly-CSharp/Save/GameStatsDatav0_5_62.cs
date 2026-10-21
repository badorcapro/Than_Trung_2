using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using GameStats;
using Tutorial;

namespace Save;

[Serializable]
public class GameStatsDatav0_5_62
{
	public List<Tutorials> tutorials_played = new List<Tutorials>();

	private Maybe<RunStats> m_combined_stats = new Maybe<RunStats>();

	public List<StatsSaveData> run_stats = new List<StatsSaveData>();

	public List<Regions> regions_discovered = new List<Regions>();

	public List<Roles> roles_discovered = new List<Roles>();

	public List<LocationTypes> location_discovered = new List<LocationTypes>();

	public List<CaseQuirks> played_case_quirks = new List<CaseQuirks>();

	public RunStats Combined
	{
		get
		{
			if (!m_combined_stats.is_some)
			{
				m_combined_stats = calculateCombinedStats().maybe();
			}
			return m_combined_stats.value;
		}
	}

	public Maybe<RunStats> previous_run { get; private set; } = new Maybe<RunStats>();

	private RunStats calculateCombinedStats()
	{
		RunStats all_stats = new RunStats(Regions.NONE);
		run_stats.ForEach(delegate(StatsSaveData _s)
		{
			all_stats.addStats(_s);
		});
		return all_stats;
	}
}
