using System;
using System.Collections.Generic;
using AlternateModes;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLib.Serializable;
using GameStats;
using Quirks;
using Tutorial;

namespace Save;

[Serializable]
public class GameStatsData
{
	private Maybe<RunStats> m_combined_stats = new Maybe<RunStats>();

	public List<Tutorials> tutorials_played = new List<Tutorials>();

	public List<StatsSaveData> run_stats = new List<StatsSaveData>();

	public List<Roles> roles_discovered = new List<Roles>();

	public List<LocationTypes> location_discovered = new List<LocationTypes>();

	public List<CaseQuirks> played_case_quirks = new List<CaseQuirks>();

	public SerializableDictionary<AlternateModeTypes, AlternateModeStatsData> alt_modes_stats;

	public List<Roles> prime_suspects_won = new List<Roles>();

	public Maybe<RunStats> previous_run { get; private set; } = new Maybe<RunStats>();

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

	private RunStats calculateCombinedStats()
	{
		RunStats all_stats = new RunStats(Regions.NONE);
		run_stats.ForEach(delegate(StatsSaveData _s)
		{
			all_stats.addStats(_s);
		});
		return all_stats;
	}

	public void addRun(RunStats _stats)
	{
		if (!previous_run.is_some || previous_run.value != _stats)
		{
			StatsSaveData statsSaveData = new StatsSaveData(_stats);
			run_stats.Add(statsSaveData);
			previous_run = _stats.maybe();
			if (m_combined_stats.is_some)
			{
				Combined.addStats(statsSaveData);
			}
		}
	}

	public void addPrimeSuspects(List<Roles> _roles)
	{
		_roles.ForEach(delegate(Roles _r)
		{
			prime_suspects_won.addIfNotDuplicate(_r);
		});
	}

	public bool hasWonWithSuspect(Roles _role)
	{
		return prime_suspects_won.Contains(_role);
	}

	public void addCaseQuirks(List<CaseQuirkData> _quirks)
	{
		_quirks.ForEach(delegate(CaseQuirkData _q)
		{
			addCaseQuirk(_q.quirk_type);
		});
	}

	public void addCaseQuirk(CaseQuirks _quirk)
	{
		if (!played_case_quirks.Contains(_quirk))
		{
			played_case_quirks.Add(_quirk);
		}
	}

	public void addDiscoveredRolesAndLocations(HashSet<Roles> _roles, HashSet<LocationTypes> _locations)
	{
		addDiscoveredRoles(_roles);
		addDiscoveredLocations(_locations);
	}

	public void addDiscoveredRoles(HashSet<Roles> _roles)
	{
		_roles.forEach(addDiscoveredRole);
	}

	public void addDiscoveredRole(Roles _role)
	{
		if (!roles_discovered.Contains(_role))
		{
			roles_discovered.Add(_role);
		}
	}

	public void addDiscoveredLocations(HashSet<LocationTypes> _locations)
	{
		_locations.forEach(addDiscoveredLocation);
	}

	public void addDiscoveredLocation(LocationTypes _location)
	{
		if (!location_discovered.Contains(_location))
		{
			location_discovered.Add(_location);
		}
	}

	public void resetPreviousRun()
	{
		previous_run = new Maybe<RunStats>();
	}

	public bool playedTutorial(Tutorials _tuto)
	{
		return tutorials_played.Contains(_tuto);
	}

	public void finishTutorial(Tutorials _tuto)
	{
		tutorials_played.addIfNotDuplicate(_tuto);
	}

	public void onAltModeFinished(AlternateModeTypes _mode, Regions _region)
	{
		alt_modes_stats[_mode] = new AlternateModeStatsData(_region);
		SteamHelper.tryAchieve(Achiements.COMPLETE_ALT_MODE);
	}

	public void onAltModeFinished(AlternateModeTypes _mode, Regions _region, Func<string, string> _override_data)
	{
		alt_modes_stats[_mode] = new AlternateModeStatsData(_region, _override_data);
		SteamHelper.tryAchieve(Achiements.COMPLETE_ALT_MODE);
	}
}
