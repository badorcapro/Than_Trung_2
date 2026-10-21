using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using GRGLib.Serializable;

namespace Save;

[Serializable]
public class CaseSavev0_4_23
{
	public CaseType case_type;

	public Maybe<int> tutorial_level;

	public bool began;

	public float difficulty_01;

	public bool case_solved;

	public SerializableDictionary<RoleClassifications, int> classification_ratio;

	public SerializableDictionary<RoleClassifications, int> public_classification_ratio;

	public List<CaseQuirks> active_case_quirks;

	public List<CaseQuirks> completed_quirks;

	public List<Roles> suspect_list;

	public Maybe<List<Roles>> visual_suspect_list;

	public List<RoleSavev0_4_23> board_roles;

	public List<LocationDataSave> board_locations;

	public SerializableDictionary<LocationTypes, LocationDataSave> location_disguises;

	public string unique_data;
}
