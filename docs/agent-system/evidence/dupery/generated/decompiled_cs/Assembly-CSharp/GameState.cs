using System;
using System.Collections.Generic;
using System.Linq;
using AlternateModes;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using GRGLib.Serializable;
using GameStats;
using Leads;
using Lineup;
using Quirks;
using Save;
using UnityEngine;

public class GameState
{
	public RunStats run_stats;

	public List<LineupClue> lineup_clues = new List<LineupClue>();

	public Maybe<(CaseType, int)> tutorial_case = new Maybe<(CaseType, int)>();

	public Regions current_region;

	public List<Lead> available_lead_choices = new List<Lead>();

	public bool in_lead;

	public List<Lead> run_leads = new List<Lead>();

	public Maybe<LeadProgressionManager> custom_progression_manager = new Maybe<LeadProgressionManager>();

	public List<LeadEventSaveData> available_event_choices = new List<LeadEventSaveData>();

	public Maybe<CaseSave> current_case = new Maybe<CaseSave>();

	public Maybe<CaseReward> case_reward = new Maybe<CaseReward>();

	public Maybe<CaseNotes> case_notes = new Maybe<CaseNotes>();

	public Maybe<AlternateModeData> alternate_mode = new Maybe<AlternateModeData>();

	public bool ignore_save { get; private set; }

	public bool is_tutorial_replay { get; private set; }

	public Maybe<Lead> current_lead
	{
		get
		{
			if (run_leads.Count != 0 && in_lead)
			{
				return run_leads[run_leads.Count - 1].maybe();
			}
			return new Maybe<Lead>();
		}
	}

	public GameState()
		: this(Regions.NONE, new Maybe<CaseType>())
	{
	}

	public GameState(Regions _run_region, Maybe<CaseType> _tutorial)
	{
		current_region = _run_region;
		run_stats = new RunStats(current_region);
		current_case = new Maybe<CaseSave>();
		tutorial_case = _tutorial.fmap((CaseType _c) => (_c: _c, 1));
	}

	public GameState(Lead _lead, LeadProgressionManager _manager)
	{
		current_region = Regions.CUSTOM;
		run_stats = new RunStats(current_region);
		current_case = new Maybe<CaseSave>();
		tutorial_case = new Maybe<(CaseType, int)>();
		custom_progression_manager = _manager.maybe();
		startLead(_lead);
	}

	public GameState(AlternateModeData _mode, Lead _lead, Maybe<LeadProgressionManager> _manager)
	{
		current_region = Regions.CUSTOM;
		run_stats = new RunStats(current_region);
		current_case = new Maybe<CaseSave>();
		tutorial_case = new Maybe<(CaseType, int)>();
		alternate_mode = _mode.maybe();
		custom_progression_manager = _manager;
		startLead(_lead);
	}

	public GameState(StatsSaveData _stats, List<LineupClueSave> _clues, Maybe<STupple<CaseType, int>> _tutorial, Regions _region, List<LeadSaveData> _available_leads, List<LeadSaveData> _current_lead, bool _in_lead, List<LeadEventSaveData> _av_events, Maybe<CaseSave> _case_save, Maybe<CaseRewardSave> _case_reward, Maybe<CaseNotes> _case_notes, Maybe<LeadProgressionManagerCustomSave> _custom_progressor, Maybe<STupple<AlternateModeTypes, string>> _mode)
	{
		run_stats = new RunStats(_stats);
		lineup_clues = _clues.Select((LineupClueSave _c) => _c.loadClue()).ToList();
		tutorial_case = _tutorial.fmap((STupple<CaseType, int> _v) => _v.get());
		current_region = _region;
		available_lead_choices = _available_leads.Select((LeadSaveData _l) => Lead.load(_l)).ToList();
		run_leads = _current_lead.Select((LeadSaveData _s) => Lead.load(_s)).ToList();
		in_lead = _in_lead;
		alternate_mode = _mode.fmap((STupple<AlternateModeTypes, string> _s) => AlternateModeData.loadData(_s.Item1, _s.Item2));
		custom_progression_manager = _custom_progressor.fmap((LeadProgressionManagerCustomSave _s) => LeadProgressionManager.load(_s, GameHandler.instance.regions_data, alternate_mode));
		available_event_choices = _av_events;
		current_case = _case_save;
		case_reward = (current_case.is_some ? _case_reward.fmap((CaseRewardSave _s) => CaseRewardSave.load(_s, current_case.value.case_type)) : new Maybe<CaseReward>());
		case_notes = _case_notes;
	}

	public void setLeadChoices(List<Lead> _leads)
	{
		available_lead_choices = _leads;
	}

	public void startLead(Lead _lead)
	{
		available_lead_choices = new List<Lead>();
		in_lead = true;
		run_leads.Add(_lead);
		run_stats.startLead(_lead);
	}

	public bool endCurrentLead()
	{
		if (!current_lead.is_some)
		{
			return false;
		}
		run_stats.onLeadEnd(current_lead.value);
		in_lead = false;
		return true;
	}

	public List<Lead> endRunGetLeads()
	{
		List<Lead> result = run_leads;
		run_leads = new List<Lead>();
		return result;
	}

	public Maybe<LineupClue> endCurrentLeadWithClue(System.Random _rng)
	{
		if (!endCurrentLead())
		{
			return new Maybe<LineupClue>();
		}
		LineupClue lineupClue = LineupClue.createClue(lineup_clues, _rng);
		lineup_clues.Add(lineupClue);
		return lineupClue.maybe();
	}

	public Regions getLeadRegion()
	{
		if (!current_lead.is_some)
		{
			return current_region;
		}
		return current_lead.value.case_type.fromType();
	}

	public Regions estimateSyndicateRegion()
	{
		if (available_lead_choices.Count <= 0)
		{
			return getLeadRegion();
		}
		return available_lead_choices[0].case_type.fromType();
	}

	public void onCaseStart(Case _case, CaseReward _reward)
	{
		current_case = _case.toSave().maybe();
		case_reward = _reward.maybe();
		case_notes = new Maybe<CaseNotes>();
		GameHandler.instance.saveGame();
	}

	public bool onTutorialSolve()
	{
		if (!tutorial_case.is_some)
		{
			return false;
		}
		GameHandler.StatsData.finishTutorial(tutorial_case.value.Item1.toTutorial());
		if (!TutorialHelper.hasNextTutorialCase(tutorial_case.value.Item1, tutorial_case.value.Item2))
		{
			tutorial_case = new Maybe<(CaseType, int)>();
			SaveHandler.instance.saveGameStats();
			GameHandler.State.current_case = new Maybe<CaseSave>();
			return false;
		}
		tutorial_case = (tutorial_case.value.Item1, tutorial_case.value.Item2 + 1).maybe();
		return true;
	}

	public void onCaseSolve(Case _case)
	{
		if (!current_lead.is_some)
		{
			Debug.LogError("Current Lead is not some when solving case!");
			resetCaseData();
			return;
		}
		if (!case_reward.is_some)
		{
			Debug.LogError("No case reward upon solving case!");
			resetCaseData();
			return;
		}
		case_reward = _case.active_quirks.Where((CaseQuirkData _q) => _q.is_case_solve_quirk).Aggregate(case_reward.value, (CaseReward _a, CaseQuirkData _q) => _q.onCaseSolved(_a, this, _case.solvedGameSnap(), _case.getPayload(), RandomExtensions.freshRandom())).maybe();
		current_lead.value.onCaseFinish(_case, case_reward.value);
		resetCaseData();
	}

	private void resetCaseData()
	{
		current_case = new Maybe<CaseSave>();
		case_reward = new Maybe<CaseReward>();
		case_notes = new Maybe<CaseNotes>();
	}

	public CaseNotes getCaseNotes()
	{
		if (!case_notes.is_some)
		{
			case_notes = new CaseNotes().maybe();
		}
		return case_notes.value;
	}

	public void setIsTutorialReplay()
	{
		is_tutorial_replay = true;
		ignore_save = true;
	}

	public void setIgnoreSave()
	{
		ignore_save = true;
	}
}
