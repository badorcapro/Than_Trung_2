using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLib.Serializable;
using Leads;
using Quirks;
using UnityEngine;

namespace Save;

[Serializable]
public class CaseSave
{
	public CaseType case_type;

	public Vector2Int board_size;

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

	public List<RoleSave> board_roles;

	public List<LocationDataSave> board_locations;

	public SerializableDictionary<LocationTypes, LocationDataSave> location_disguises;

	public string unique_data;

	public static CaseSave loadCase(string _json)
	{
		return JsonUtility.FromJson<CaseSave>(_json);
	}

	public static Case toCase(CaseSave _save)
	{
		return toCase(_save, new Maybe<Lead>());
	}

	public static Case toCase(CaseSave _save, Maybe<Lead> _current_lead)
	{
		return _save.case_type switch
		{
			CaseType.CLOCK => new ClockCase(_save, _current_lead), 
			CaseType.DOCKS => new DocksCase(_save, _current_lead), 
			CaseType.CASINO => new CasinoCase(_save, _current_lead), 
			CaseType.BACK_ALLEYS => new BackAlleysCase(_save, _current_lead), 
			_ => throw new ArgumentException($"No toCase function set up for case type {_save.case_type}"), 
		};
	}

	public CaseSave(CaseType _case_type, Vector2Int _board_size, bool _began, float _diff, bool _case_solved, List<CaseQuirkData> _case_quirks, Dictionary<RoleClassifications, int> _ratio, Dictionary<RoleClassifications, int> _public_ratio, HashSet<RoleData> _suspects, Maybe<HashSet<RoleData>> _visual_suspects, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Maybe<int> _tutorial, string _unique_data)
	{
		case_type = _case_type;
		board_size = _board_size;
		tutorial_level = _tutorial;
		began = _began;
		unique_data = _unique_data;
		difficulty_01 = _diff;
		active_case_quirks = _case_quirks.Select((CaseQuirkData _q) => _q.quirk_type).ToList();
		completed_quirks = (from _q in _case_quirks
			where _q.quirk_completed
			select _q.quirk_type).ToList();
		case_solved = _case_solved;
		classification_ratio = _ratio.makeSerializable();
		public_classification_ratio = _public_ratio.makeSerializable();
		suspect_list = _suspects.Select((RoleData _r) => _r.role).ToList();
		visual_suspect_list = (_visual_suspects.is_some ? _visual_suspects.value.Select((RoleData _r) => _r.role).ToList().maybe() : new Maybe<List<Roles>>());
		board_roles = new List<RoleSave>();
		board_locations = new List<LocationDataSave>();
		location_disguises = new SerializableDictionary<LocationTypes, LocationDataSave>();
		foreach (KeyValuePair<Vector2Int, Maybe<Either<RoleData, LocationData>>> item in _board)
		{
			if (!item.Value.is_some)
			{
				continue;
			}
			if (item.Value.value.is_a)
			{
				board_roles.Add(item.Value.value.maybe_a.value.toSave());
				continue;
			}
			LocationData value = item.Value.value.maybe_b.value;
			board_locations.Add(value.toSave());
			if (value.is_location_disguised)
			{
				location_disguises[value.location_type] = value.getDisguiseSave();
			}
		}
	}

	public CaseSave(CaseSavev0_3_12 _old_case)
	{
		case_type = CaseType.CLOCK;
		tutorial_level = _old_case.tutorial_level;
		began = _old_case.began;
		unique_data = $"{_old_case.reputation},{_old_case.hours_passed}";
		difficulty_01 = _old_case.difficulty_01;
		case_solved = _old_case.case_solved;
		classification_ratio = _old_case.classification_ratio;
		public_classification_ratio = _old_case.public_classification_ratio;
		active_case_quirks = _old_case.active_case_quirks;
		completed_quirks = _old_case.completed_quirks;
		suspect_list = _old_case.suspect_list;
		visual_suspect_list = new Maybe<List<Roles>>();
		board_roles = _old_case.board_roles.Select((RoleDataSaveV0_3_12 _r) => new RoleSave(_r, _old_case.board_disguises.ContainsKey(_r.address) ? _old_case.board_disguises[_r.address].maybe() : new Maybe<RoleDataSaveV0_3_12>())).ToList();
		board_locations = _old_case.board_locations;
		location_disguises = _old_case.location_disguises;
	}

	public CaseSave(CaseSavev0_4_23 _old_case)
	{
		case_type = _old_case.case_type;
		tutorial_level = _old_case.tutorial_level;
		began = _old_case.began;
		difficulty_01 = _old_case.difficulty_01;
		case_solved = _old_case.case_solved;
		classification_ratio = _old_case.classification_ratio;
		public_classification_ratio = _old_case.public_classification_ratio;
		active_case_quirks = _old_case.active_case_quirks;
		completed_quirks = _old_case.completed_quirks;
		suspect_list = _old_case.suspect_list;
		visual_suspect_list = new Maybe<List<Roles>>();
		board_roles = _old_case.board_roles.Aggregate(new List<RoleSave>(), (List<RoleSave> _a, RoleSavev0_4_23 _s) => _a.add(_s.convert()));
		board_locations = _old_case.board_locations;
		location_disguises = _old_case.location_disguises;
		unique_data = _old_case.unique_data;
	}
}
