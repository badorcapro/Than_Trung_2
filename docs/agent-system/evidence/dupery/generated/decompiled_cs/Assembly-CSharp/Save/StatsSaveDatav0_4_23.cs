using System;

namespace Save;

[Serializable]
public class StatsSaveDatav0_4_23
{
	public bool run_won;

	public bool demo_run;

	public float play_time;

	public int cases_attempted;

	public int cases_solved;

	public int cases_flawless;

	public CaseStatsSaveDatav0_4_24 combined_case_stats;

	public StatsSaveData convertNewer()
	{
		return new StatsSaveData
		{
			run_won = run_won
		};
	}
}
