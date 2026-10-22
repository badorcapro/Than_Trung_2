using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Generic;
using Leads;
using UnityEngine;

namespace Save;

[Serializable]
public class LeadSaveData
{
	public CaseType case_type;

	public List<Roles> available_roles;

	public List<Vector2Int> grid_sizes;

	public MinMaxFloat lead_difficulty;

	public int max_case;

	public int current_case;

	public RoleSetInfoStruct prime_suspect_set;

	public List<ClueSaveData> clues;

	public List<StampInfo> stamp_info;

	public string unique_data;

	public LeadSaveData(Lead _lead)
	{
		case_type = ((_lead is CaseToCaseLead) ? ((CaseType)(-1)) : _lead.case_type);
		available_roles = _lead.lead_roles;
		grid_sizes = _lead.getGridSizes();
		lead_difficulty = _lead.lead_difficulty;
		max_case = _lead.max_case;
		current_case = _lead.current_case;
		prime_suspect_set = _lead.prime_suspect_set;
		clues = _lead.clues.Select((Clue _c) => new ClueSaveData(_c)).ToList();
		stamp_info = _lead.stamps.copy();
		unique_data = _lead.uniqueSaveData();
	}
}
