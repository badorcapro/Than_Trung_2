using System;
using GameStats;

namespace Save;

[Serializable]
public class LeadStatsSaveData
{
	public CaseType case_type;

	public float play_time;

	public bool lead_completed;

	public int cases_attempted;

	public int cases_solved;

	public int cases_flawless;

	public CaseStatsSaveData combined_case_stats;

	public LeadStatsSaveData(LeadStats _stats)
	{
		case_type = _stats.case_type;
		play_time = _stats.play_time;
		lead_completed = _stats.lead_completed;
		cases_attempted = _stats.cases_attempted;
		cases_solved = _stats.cases_solved;
		cases_flawless = _stats.cases_flawless;
		combined_case_stats = new CaseStatsSaveData(_stats.combined_case_stats);
	}
}
