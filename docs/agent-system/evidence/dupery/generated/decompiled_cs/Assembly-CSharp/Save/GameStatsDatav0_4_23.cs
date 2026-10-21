using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;

namespace Save;

[Serializable]
public class GameStatsDatav0_4_23
{
	public bool played_tutorial;

	public List<StatsSaveDatav0_4_23> run_stats = new List<StatsSaveDatav0_4_23>();

	public List<Roles> roles_discovered = new List<Roles>();

	public List<LocationTypes> location_discovered = new List<LocationTypes>();

	public List<CaseQuirks> played_case_quirks = new List<CaseQuirks>();

	public GameStatsData convertNewer()
	{
		return new GameStatsData
		{
			run_stats = run_stats.Aggregate(new List<StatsSaveData>(), (List<StatsSaveData> _a, StatsSaveDatav0_4_23 _s) => _a.add(_s.convertNewer())),
			roles_discovered = roles_discovered.copy(),
			location_discovered = location_discovered.copy(),
			played_case_quirks = played_case_quirks.copy()
		};
	}
}
