using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Leads;
using Quirks;
using UnityEngine;

namespace CaseCreation;

public class SuspectListFactory
{
	public class SuspectListFactoryResult
	{
		public List<Roles> suspect_list { get; private set; } = new List<Roles>();

		public List<LocationTypes> wanted_locations { get; private set; } = new List<LocationTypes>();

		public SuspectListFactoryResult(List<Roles> _suspect_list, List<LocationTypes> _locations)
		{
			suspect_list = _suspect_list;
			wanted_locations = _locations;
		}
	}

	protected Action<string> print_error;

	protected System.Random random;

	protected Func<Roles, RoleData> role_getter;

	protected Dictionary<RoleClassifications, int> ratio;

	protected LocationTypes starting_location;

	protected int space_for_locations;

	protected float difficulty_01;

	protected Dictionary<RoleClassifications, int> suspect_list_ratio;

	protected List<Roles> lead_roles = new List<Roles>();

	protected List<Roles> forced_in_play = new List<Roles>();

	protected List<Marker<Roles>> attempted_role_list;

	protected List<Marker<LocationTypes>> attempted_location_list;

	protected List<CaseQuirkData> quirks;

	public Either<string, SuspectListFactoryResult> result = new Either<string, SuspectListFactoryResult>("NOT BUILT");

	public List<Roles> forced_suspected { get; protected set; } = new List<Roles>();

	public List<Roles> forced_not_suspected { get; protected set; } = new List<Roles>();

	public SuspectListFactory(float _diff_01, Dictionary<RoleClassifications, int> _ratio, int _available_spaces, List<Roles> _prime_suspects, List<Clue> _clues, List<Roles> _lead_roles, LocationTypes _starting_location, List<CaseQuirkData> _quirks, Func<Roles, RoleData> _role_getter, System.Random _rng, Action<string> _error)
	{
		print_error = _error;
		random = _rng;
		role_getter = _role_getter;
		ratio = _ratio;
		difficulty_01 = _diff_01;
		starting_location = _starting_location;
		quirks = _quirks;
		(List<Roles>, List<Roles>, List<Roles>) tuple = _clues.Aggregate((new List<Roles>(), new List<Roles>(), new List<Roles>()), delegate((List<Roles>, List<Roles>, List<Roles>) _a, Clue _r)
		{
			if (!(_r is RoleClue roleClue))
			{
				return _a;
			}
			if (roleClue.clue_type == ClueTypes.ROLE_IN_PLAY)
			{
				return (_a.Item1.add(roleClue.role_in_focus), _a.Item2, _a.Item3.add(roleClue.role_in_focus));
			}
			if (roleClue.clue_type == ClueTypes.ROLE_SUSPECTED)
			{
				return (_a.Item1.add(roleClue.role_in_focus), _a.Item2, _a.Item3);
			}
			return (roleClue.clue_type == ClueTypes.ROLE_NOT_IN_PLAY) ? (_a.Item1, _a.Item2.add(roleClue.role_in_focus), _a.Item3) : _a;
		});
		forced_suspected = tuple.Item1.addRange(_prime_suspects);
		forced_not_suspected = tuple.Item2;
		forced_in_play = tuple.Item3;
		lead_roles = _lead_roles;
		space_for_locations = _available_spaces - ratio.sumValues();
		result = createSuspectList();
	}

	public Either<string, SuspectListFactoryResult> createSuspectList()
	{
		suspect_list_ratio = createSuspectListRatio();
		attempted_role_list = new List<Marker<Roles>>();
		attempted_location_list = new List<Marker<LocationTypes>>
		{
			new Marker<LocationTypes>(starting_location, _locked: true)
		};
		List<Roles> list = lead_roles.Where((Roles _r) => !forced_not_suspected.Contains(_r)).ToList();
		foreach (Roles item in forced_suspected)
		{
			if (suspect_list_ratio[item.getClassificationFromRoleType()] != 0 && !tryAddRoleToSuspectList(item, attempted_role_list, list, _forced: true))
			{
				return new Either<string, SuspectListFactoryResult>($"Failed to add forced suspect {item}!");
			}
		}
		if (!fillClassification(RoleClassifications.TRAITOR, attempted_role_list, list, 0))
		{
			return new Either<string, SuspectListFactoryResult>("Failed to fill out traitors in suspect list");
		}
		if (!fillClassification(RoleClassifications.UNDERLING, attempted_role_list, list, 1))
		{
			return new Either<string, SuspectListFactoryResult>("Failed to fill out underlings in suspect list");
		}
		if (!fillClassification(RoleClassifications.MEDDLER, attempted_role_list, list, 1))
		{
			return new Either<string, SuspectListFactoryResult>("Failed to fill out meddlers in suspect list");
		}
		if (!fillClassification(RoleClassifications.INNOCENT, attempted_role_list, list, 4))
		{
			return new Either<string, SuspectListFactoryResult>("Failed to fill out innocents in suspect list");
		}
		return new Either<string, SuspectListFactoryResult>(new SuspectListFactoryResult(attempted_role_list.Select((Marker<Roles> _m) => _m.data).ToList(), attempted_location_list.Select((Marker<LocationTypes> _m) => _m.data).ToList()));
	}

	public bool externalTryAddAnySuspect(List<Roles> _roles, List<Roles> _from, List<Marker<Roles>> _current_list, List<Roles> _available_roles, bool _allow_ratio_increase, bool _forced, bool _locked, int _desired = 1)
	{
		List<Marker<Roles>> list = _current_list.copy();
		List<Roles> list2 = _available_roles.copy();
		_roles.shuffle(random);
		int num = 0;
		while (num < _desired && _roles.Count > 0)
		{
			List<Marker<Roles>> list3 = list.copy();
			List<Roles> list4 = list2.copy();
			if (externalTryAddSuspect(_roles[0], _from, list, list2, _allow_ratio_increase, _forced, _locked))
			{
				num++;
			}
			else
			{
				list = list3;
				list2 = list4;
			}
			_roles.RemoveAt(0);
		}
		if (num == _desired)
		{
			_current_list.Clear();
			_current_list.addRange(list);
			_available_roles.Clear();
			_available_roles.addRange(list2);
			return true;
		}
		return false;
	}

	public bool externalTryAddSuspect(Roles _role, List<Roles> _from, List<Marker<Roles>> _current_list, List<Roles> _available_roles, bool _allow_ratio_increase, bool _forced, bool _locked)
	{
		if (_from.Contains(_role))
		{
			return true;
		}
		RoleClassifications role_class = _role.getClassificationFromRoleType();
		if (!_allow_ratio_increase && _from.Count((Roles _r) => _r.getClassificationFromRoleType() == role_class) + _current_list.Count((Marker<Roles> _m) => _m.data.getClassificationFromRoleType() == role_class) >= suspect_list_ratio[role_class])
		{
			return false;
		}
		return tryAddRoleToSuspectList(_role, _from, _current_list, _available_roles, _forced, _locked);
	}

	protected bool tryAddRoleToSuspectList(Roles _role, List<Marker<Roles>> _current_list, List<Roles> _available_roles, bool _forced = false)
	{
		return tryAddRoleToSuspectList(_role, new List<Roles>(), _current_list, _available_roles, _forced, _forced);
	}

	protected bool tryAddRoleToSuspectList(Roles _role, List<Roles> _from, List<Marker<Roles>> _current_list, List<Roles> _available_roles, bool _forced, bool _locked)
	{
		if (attempted_role_list.Any((Marker<Roles> _m) => _m.data == _role))
		{
			return true;
		}
		if (!_forced && suspect_list_ratio[_role.getClassificationFromRoleType()] == 0)
		{
			return false;
		}
		RoleGenerationConstraints generation_constraint = role_getter(_role).generation_constraint;
		foreach (IClassificationGenerationConstraint item in generation_constraint.getConstraintOfInterface<IClassificationGenerationConstraint>())
		{
			if (!item.canSuspectWithRatio(ratio, forced_suspected, forced_in_play, this))
			{
				return false;
			}
		}
		List<ISuspectListGenerationConstraint> constraintOfInterface = generation_constraint.getConstraintOfInterface<ISuspectListGenerationConstraint>();
		bool flag = false;
		foreach (ISuspectListGenerationConstraint item2 in constraintOfInterface)
		{
			if (!item2.tryAddSuspect(_role, _forced, _from, _current_list, _available_roles, this))
			{
				return false;
			}
			flag = flag || item2.lock_self_suspect;
		}
		foreach (CaseQuirkData quirk in quirks)
		{
			if (quirk.is_suspect_addition_quirk)
			{
				Maybe<Roles> maybe = quirk.onSuspectAddition(_role, _forced, _from);
				if (maybe.is_some && !externalTryAddSuspect(maybe.value, _from, _current_list, _available_roles, _allow_ratio_increase: true, _forced, _locked: true))
				{
					return false;
				}
			}
		}
		foreach (CaseQuirkData quirk2 in quirks)
		{
			if (!quirk2.is_suspect_removal_quirk)
			{
				continue;
			}
			Maybe<Roles> to_remove = quirk2.onSuspectRemoval(_role, _forced, _from);
			if (to_remove.is_some)
			{
				if (_role == to_remove.value || _from.Contains(to_remove.value) || _current_list.Any((Marker<Roles> _m) => _m.data == to_remove.value))
				{
					return false;
				}
				_available_roles.Remove(to_remove.value);
			}
		}
		_current_list.Add(new Marker<Roles>(_role, _locked || flag));
		return true;
	}

	public bool externalAddLocation(LocationTypes _location, bool _locked)
	{
		if (attempted_location_list.Any((Marker<LocationTypes> _m) => _m.data == _location))
		{
			return true;
		}
		if (space_for_locations <= attempted_location_list.Count)
		{
			return false;
		}
		attempted_location_list.Add(new Marker<LocationTypes>(_location, _locked));
		return true;
	}

	private Dictionary<RoleClassifications, int> createSuspectListRatio()
	{
		Dictionary<RoleClassifications, int> second = quirks.Aggregate(new Dictionary<RoleClassifications, int>(), (Dictionary<RoleClassifications, int> _a, CaseQuirkData _q) => (!_q.is_suspects_ratio_quirk) ? _a : _q.onSuspectRatio(_a, ratio, random));
		return new Dictionary<RoleClassifications, int>
		{
			{
				RoleClassifications.INNOCENT,
				ratio[RoleClassifications.INNOCENT] + Mathf.Clamp(ratio[RoleClassifications.MEDDLER] + ratio[RoleClassifications.UNDERLING] + ratio[RoleClassifications.TRAITOR], 2, 8)
			},
			{
				RoleClassifications.MEDDLER,
				(ratio[RoleClassifications.MEDDLER] != 0) ? (ratio[RoleClassifications.MEDDLER] + ((difficulty_01 > 0.2f) ? ((!(difficulty_01 > 0.8f)) ? 1 : 2) : 0)) : 0
			},
			{
				RoleClassifications.UNDERLING,
				ratio[RoleClassifications.UNDERLING] + ((difficulty_01 > 0.4f) ? ((!(difficulty_01 > 0.85f)) ? 1 : 2) : 0)
			},
			{
				RoleClassifications.TRAITOR,
				(ratio[RoleClassifications.TRAITOR] != 0) ? (ratio[RoleClassifications.TRAITOR] + ((difficulty_01 > 0.5f) ? ((!(difficulty_01 > 0.9f)) ? 1 : 2) : 0)) : 0
			}
		}.increaseOrCreateRange(second);
	}

	private bool fillClassification(RoleClassifications _class, List<Marker<Roles>> _current, List<Roles> _available, int _min_extra = 1)
	{
		if (!fillClassification(_class, attempted_role_list, _available) && attempted_role_list.Count((Marker<Roles> _m) => _m.data.getClassificationFromRoleType() == RoleClassifications.INNOCENT) < ratio[_class] + _min_extra)
		{
			return false;
		}
		return true;
	}

	private bool fillClassification(RoleClassifications _class, List<Marker<Roles>> _current, List<Roles> _available)
	{
		if (suspect_list_ratio[_class] == 0)
		{
			return true;
		}
		int num = _current.Count((Marker<Roles> _m) => _m.data.getClassificationFromRoleType() == _class);
		if (num >= suspect_list_ratio[_class])
		{
			return true;
		}
		List<Roles> list = _available.Where((Roles _r) => _r.getClassificationFromRoleType() == _class).ToList();
		list.shuffle(random);
		while (num < suspect_list_ratio[_class])
		{
			if (list.Count == 0)
			{
				return false;
			}
			List<Marker<Roles>> e = _current.copy();
			List<Roles> e2 = _available.copy();
			if (_available.Contains(list[0]) && tryAddRoleToSuspectList(list[0], _current, _available))
			{
				num = _current.Count((Marker<Roles> _m) => _m.data.getClassificationFromRoleType() == _class);
			}
			else
			{
				_current.Clear();
				_current.addRange(e);
				_available.Clear();
				_available.addRange(e2);
			}
			_available.Remove(list[0]);
			list.RemoveAt(0);
		}
		_available.removeAll((Roles _r) => _r.getClassificationFromRoleType() == _class);
		return true;
	}

	public static List<ValidationError> validateSuspectList(CaseType _type, CaseSnapshot _snap, List<Roles> _suspect_list)
	{
		List<ValidationError> errors = new List<ValidationError>();
		List<Roles> roles_in_play = _snap.address_occupents.Select((KeyValuePair<int, RoleData> _kvp) => _kvp.Value.role).ToList();
		List<Roles> list = _suspect_list.Where((Roles _r) => !roles_in_play.Contains(_r) && _r.getClassificationFromRoleType() == RoleClassifications.INNOCENT).ToList();
		List<Roles> list2 = new List<Roles>();
		foreach (Roles item in _suspect_list)
		{
			RoleData roleData = item.createEmptyRole();
			foreach (ISuspectListGenerationConstraint item2 in roleData.generation_constraint.getConstraintOfInterface<ISuspectListGenerationConstraint>())
			{
				Maybe<ValidationError> maybe = item2.checkSuspectListForError(_type, item, _suspect_list, _snap);
				errors.addIfSome(maybe);
			}
			if (list.Contains(item) && roleData.generation_constraint.isOfMarker(RoleGenerationMarkers.CANT_BE_ONLY_NOT_IN_PLAY))
			{
				list2.Add(item);
			}
		}
		if (list2.Count == list.Count)
		{
			list2.ForEach(delegate(Roles _r)
			{
				errors.Add(new SpecialEEB(SpecialEEB.SpecialErrors.CANT_BE_ONLY_INNOCENT_SUSPECT).createValidationError(_r));
			});
		}
		if (list.Count == 0)
		{
			errors.Add(new SpecialEEB(SpecialEEB.SpecialErrors.MUST_HAVE_INNOCENT_SUSPECT).createValidationError());
		}
		return errors;
	}
}
