using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Leads;
using Save;
using UnityEngine;

namespace GameStats;

public class RunStats
{
	public Regions run_region;

	public bool run_won;

	public List<LeadStats> lead_stats;

	public Maybe<LeadStats> current_lead = new Maybe<LeadStats>();

	private Maybe<CombinedCaseStats> m_combined_stats = new Maybe<CombinedCaseStats>();

	private Maybe<float> play_timer_last = new Maybe<float>();

	public float play_time => lead_stats.Aggregate(0f, (float _a, LeadStats _l) => _a + _l.play_time);

	public int cases_attempted_all => lead_stats.Aggregate(0, (int _a, LeadStats _l) => _a + _l.cases_attempted);

	public int cases_solved_all => lead_stats.Aggregate(0, (int _a, LeadStats _l) => _a + _l.cases_solved);

	public int cases_flawless_all => lead_stats.Aggregate(0, (int _a, LeadStats _l) => _a + _l.cases_flawless);

	public CombinedCaseStats combined_stats
	{
		get
		{
			if (!m_combined_stats.is_some)
			{
				m_combined_stats = lead_stats.Aggregate(new CombinedCaseStats(), (CombinedCaseStats _a, LeadStats _l) => _a.addStats(_l.combined_case_stats) as CombinedCaseStats).maybe();
			}
			return m_combined_stats.value;
		}
	}

	public OfficeCaseStats office_stats => lead_stats.Aggregate(new OfficeCaseStats(), (OfficeCaseStats _a, LeadStats _l) => (_l.case_type != 0 || !(_l.combined_case_stats is OfficeCaseStats stats)) ? _a : (_a.addStats(stats) as OfficeCaseStats));

	public CasinoCaseStats casino_stats => lead_stats.Aggregate(new CasinoCaseStats(), (CasinoCaseStats _a, LeadStats _l) => (_l.case_type != CaseType.CASINO || !(_l.combined_case_stats is CasinoCaseStats stats)) ? _a : (_a.addStats(stats) as CasinoCaseStats));

	public DocksCaseStats docks_stats => lead_stats.Aggregate(new DocksCaseStats(), (DocksCaseStats _a, LeadStats _l) => (_l.case_type != CaseType.DOCKS || !(_l.combined_case_stats is DocksCaseStats stats)) ? _a : (_a.addStats(stats) as DocksCaseStats));

	public BackAlleyCaseStats back_alley_stats => lead_stats.Aggregate(new BackAlleyCaseStats(), (BackAlleyCaseStats _a, LeadStats _l) => (_l.case_type != CaseType.BACK_ALLEYS || !(_l.combined_case_stats is BackAlleyCaseStats stats)) ? _a : (_a.addStats(stats) as BackAlleyCaseStats));

	public int getCasesAttempted(CaseType _type)
	{
		return lead_stats.Aggregate(0, (int _a, LeadStats _l) => _a + ((_l.case_type == _type) ? _l.cases_attempted : 0));
	}

	public int getCasesSolved(CaseType _type)
	{
		return lead_stats.Aggregate(0, (int _a, LeadStats _l) => _a + ((_l.case_type == _type) ? _l.cases_solved : 0));
	}

	public int getCasesFlawless(CaseType _type)
	{
		return lead_stats.Aggregate(0, (int _a, LeadStats _l) => _a + ((_l.case_type == _type) ? _l.cases_flawless : 0));
	}

	public CaseStats getCaseStats(CaseType _type)
	{
		return _type switch
		{
			CaseType.CLOCK => office_stats, 
			CaseType.CASINO => casino_stats, 
			CaseType.DOCKS => docks_stats, 
			CaseType.BACK_ALLEYS => back_alley_stats, 
			_ => throw new ArgumentException($"No case stats getter set up for case type {_type}!"), 
		};
	}

	public RunStats(Regions _run_region)
	{
		run_region = _run_region;
		run_won = false;
		lead_stats = new List<LeadStats>();
		m_combined_stats = new Maybe<CombinedCaseStats>();
		current_lead = new Maybe<LeadStats>();
	}

	public RunStats(StatsSaveData _save)
	{
		run_region = _save.region;
		run_won = _save.run_won;
		lead_stats = _save.lead_stats.Select((LeadStatsSaveData _s) => new LeadStats(_s)).ToList();
		current_lead = _save.current_stats.fmap((LeadStatsSaveData _s) => new LeadStats(_s));
	}

	public void onCaseEnd(CaseStats _stats, CaseType _type, bool _success, bool _flawless)
	{
		if (!current_lead.is_some)
		{
			Debug.LogError("Finished case while not in lead? No current lead stats set up!");
			return;
		}
		if (current_lead.value.case_type != _type)
		{
			Debug.LogError($"Finished case of type {_type} but current lead is of type {current_lead.value.case_type}! This disrepency is not allowed!");
			return;
		}
		current_lead.value.cases_attempted++;
		if (_success)
		{
			current_lead.value.cases_solved++;
			if (_flawless)
			{
				current_lead.value.cases_flawless++;
			}
		}
		current_lead.value.combined_case_stats.addStats(_stats);
		m_combined_stats = new Maybe<CombinedCaseStats>();
	}

	public void startLead(Lead _lead)
	{
		if (current_lead.is_some)
		{
			Debug.LogError("Lead stats already exists! Please call onLeadEnd before startLead!");
		}
		current_lead = new LeadStats(_lead.case_type).maybe();
	}

	public void onLeadEnd(Lead _lead)
	{
		if (current_lead.is_some)
		{
			stopTimer();
			current_lead.value.lead_completed = _lead.is_lead_completed;
			lead_stats.Add(current_lead.value);
			current_lead = new Maybe<LeadStats>();
		}
	}

	public void addStats(StatsSaveData _save)
	{
		lead_stats.AddRange(_save.lead_stats.Select((LeadStatsSaveData _s) => new LeadStats(_s)));
		m_combined_stats = new Maybe<CombinedCaseStats>();
	}

	public void startTimer()
	{
		if (current_lead.is_some)
		{
			play_timer_last = Time.realtimeSinceStartup.maybe();
		}
	}

	public void refreshTimer()
	{
		if (current_lead.is_some)
		{
			if (!play_timer_last.is_some)
			{
				startTimer();
				return;
			}
			current_lead.value.play_time += Time.realtimeSinceStartup - play_timer_last.value;
			play_timer_last = Time.realtimeSinceStartup.maybe();
		}
	}

	public void stopTimer()
	{
		if (play_timer_last.is_some)
		{
			if (!current_lead.is_some)
			{
				Debug.LogError("Timer is useless?! No current lead!");
				play_timer_last = new Maybe<float>();
			}
			else
			{
				current_lead.value.play_time += Time.realtimeSinceStartup - play_timer_last.value;
				play_timer_last = new Maybe<float>();
			}
		}
	}
}
