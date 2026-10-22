using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using Leads;
using UnityEngine;

namespace MainMenu;

[Serializable]
public struct CustomLeadPreset
{
	public Regions region;

	public int lead_length;

	public Vector2Int board_size;

	public MinMaxFloat difficulty;

	public RoleSetInfoStruct prime_suspects;

	public List<Roles> available_roles;

	public List<CaseQuirks> available_quirks;

	public List<CaseQuirks> starting_quirks;

	public string override_settings;

	public int traitor_cases;

	public CustomLeadPreset(Lead _lead, LeadProgressionManager _prog)
	{
		region = _lead.case_type.fromType();
		lead_length = _lead.max_case;
		board_size = _lead.current_board_size;
		difficulty = _lead.lead_difficulty;
		prime_suspects = _lead.prime_suspect_set;
		available_roles = _lead.lead_roles.copy();
		available_quirks = (_prog.available_quirks.is_some ? _prog.available_quirks.value.copy() : new List<CaseQuirks>());
		starting_quirks = _lead.clues.whereSelect((Clue _c) => _c is QuirkClue, (Clue _q) => (_q as QuirkClue).quirk_in_focus).ToList();
		override_settings = _prog.getOverrideSaveData();
		traitor_cases = _lead.forced_end_traitor_cases;
	}
}
