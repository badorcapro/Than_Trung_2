using Save;

namespace GameStats;

public class LeadStats
{
	public CaseType case_type;

	public float play_time;

	public bool lead_completed;

	public int cases_attempted;

	public int cases_solved;

	public int cases_flawless;

	public CaseStats combined_case_stats;

	public LeadStats(CaseType _type)
	{
		case_type = _type;
		combined_case_stats = CaseStats.createEmpty(_type);
	}

	public LeadStats(LeadStatsSaveData _save)
	{
		case_type = _save.case_type;
		play_time = _save.play_time;
		lead_completed = _save.lead_completed;
		cases_attempted = _save.cases_attempted;
		cases_solved = _save.cases_solved;
		cases_flawless = _save.cases_flawless;
		combined_case_stats = CaseStats.load(_save.combined_case_stats, _save.case_type);
	}
}
