using System;
using System.Collections.Generic;
using System.Linq;
using AlternateModes;
using GRGLib.Maybe;
using GRGLib.Serializable;
using Leads;
using Lineup;

namespace Save;

[Serializable]
public class SaveData : BaseSaveData
{
	public StatsSaveData run_stats;

	public List<LineupClueSave> clues;

	public Maybe<STupple<CaseType, int>> tutorial;

	public Regions region;

	public List<LeadSaveData> available_leads;

	public List<LeadSaveData> run_leads;

	public bool in_lead;

	public Maybe<LeadProgressionManagerCustomSave> custom_progressor;

	public List<LeadEventSaveData> available_events;

	public Maybe<CaseSave> current_case;

	public Maybe<CaseRewardSave> reward;

	public Maybe<PinsSave> pins_data = new Maybe<PinsSave>();

	public Maybe<LinesSave> lines_data = new Maybe<LinesSave>();

	public Maybe<StringSave> strings_data = new Maybe<StringSave>();

	public Maybe<STupple<AlternateModeTypes, string>> alt_mode;

	public SaveData(string _scene, GameState _state)
		: base(_scene)
	{
		run_stats = new StatsSaveData(_state.run_stats);
		clues = _state.lineup_clues.Select((LineupClue _c) => _c.getSave()).ToList();
		tutorial = _state.tutorial_case.fmap(((CaseType, int) _t) => new STupple<CaseType, int>(_t.Item1, _t.Item2));
		region = _state.current_region;
		available_leads = _state.available_lead_choices.Select((Lead _l) => new LeadSaveData(_l)).ToList();
		run_leads = _state.run_leads.Select((Lead _r) => new LeadSaveData(_r)).ToList();
		in_lead = _state.in_lead;
		custom_progressor = _state.custom_progression_manager.fmap((LeadProgressionManager _p) => new LeadProgressionManagerCustomSave(_p));
		available_events = _state.available_event_choices;
		current_case = _state.current_case;
		reward = _state.case_reward.fmap((CaseReward _r) => _r.toSave());
		if (_state.current_case.is_some && _state.case_notes.is_some)
		{
			pins_data = _state.case_notes.value.pins_data.maybe();
			lines_data = _state.case_notes.value.lines_data.maybe();
			strings_data = _state.case_notes.value.strings_data.maybe();
		}
		else
		{
			pins_data = new Maybe<PinsSave>();
			lines_data = new Maybe<LinesSave>();
			strings_data = new Maybe<StringSave>();
		}
		alt_mode = _state.alternate_mode.fmap((AlternateModeData _m) => (_m is IModeWithData modeWithData) ? new STupple<AlternateModeTypes, string>(_m.mode_type, modeWithData.toSave()) : new STupple<AlternateModeTypes, string>(_m.mode_type, ""));
	}

	public override GameState toGameState()
	{
		Maybe<CaseNotes> case_notes = ((pins_data.is_some || lines_data.is_some || strings_data.is_some) ? new CaseNotes(pins_data, lines_data, strings_data).maybe() : new Maybe<CaseNotes>());
		return new GameState(run_stats, clues, tutorial, region, available_leads, run_leads, in_lead, available_events, current_case, reward, case_notes, custom_progressor, alt_mode);
	}

	public override void onLoaded()
	{
	}
}
