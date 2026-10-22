using System;
using GRGLib.Serializable;

namespace Save;

[Serializable]
public class StatsSaveDatav0_5_62
{
	public bool run_won;

	public bool demo_run;

	public float play_time;

	public SerializableDictionary<CaseType, int> cases_attempted;

	public SerializableDictionary<CaseType, int> cases_solved;

	public SerializableDictionary<CaseType, int> cases_flawless;

	public SerializableDictionary<Regions, int> regions_completed;

	public Regions last_region;

	public SerializableDictionary<CaseType, CaseStatsSaveData> combined_case_stats;
}
