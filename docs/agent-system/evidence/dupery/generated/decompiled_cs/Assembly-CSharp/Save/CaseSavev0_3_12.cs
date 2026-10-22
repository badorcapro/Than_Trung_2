using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using GRGLib.Serializable;
using UnityEngine;

namespace Save;

[Serializable]
public class CaseSavev0_3_12
{
	public Maybe<int> tutorial_level;

	public bool began;

	public int hours_passed;

	public int reputation;

	public float difficulty_01;

	public bool case_solved;

	public SerializableDictionary<RoleClassifications, int> classification_ratio;

	public SerializableDictionary<RoleClassifications, int> public_classification_ratio;

	public List<CaseQuirks> active_case_quirks;

	public List<CaseQuirks> completed_quirks;

	public List<Roles> suspect_list;

	public List<RoleDataSaveV0_3_12> board_roles;

	public List<LocationDataSave> board_locations;

	public SerializableDictionary<int, RoleDataSaveV0_3_12> board_disguises;

	public SerializableDictionary<LocationTypes, LocationDataSave> location_disguises;

	public static CaseSave loadCase(string _json)
	{
		return new CaseSave(JsonUtility.FromJson<CaseSavev0_3_12>(_json));
	}
}
