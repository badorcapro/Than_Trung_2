using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

public class SuspectRequireRoleGC : AdvancedGenerationConstraint, ISuspectListGenerationConstraint, IFilterRoleCluesGenerationConstraint
{
	protected int roles_required = 1;

	protected Func<Roles, bool> is_target;

	protected bool lock_self;

	protected bool allow_suspect_ratio_increase;

	protected EditorErrorBuilder error_builder;

	public bool lock_self_suspect => lock_self;

	public SuspectRequireRoleGC(Roles _role, bool _lock_self = true)
	{
		Func<Roles, bool> func = (Roles _r) => _r == _role;
		bool flag = _lock_self;
		EditorErrorBuilder editorErrorBuilder = new RequirementEEB(_role);
		is_target = func;
		roles_required = 1;
		lock_self = flag;
		error_builder = editorErrorBuilder;
	}

	public SuspectRequireRoleGC(RoleClassifications _class, int _wanted = 1, bool _true_class = false, bool _lock_self = true)
	{
		if (_true_class)
		{
			is_target = (Roles _r) => _r.getClassificationFromRoleType() == _class;
		}
		else
		{
			is_target = (Roles _r) => _r.createEmptyRole().getVisualClassification() == _class;
		}
		roles_required = _wanted;
		lock_self = _lock_self;
		allow_suspect_ratio_increase = true;
		error_builder = new RequirementEEB(_class);
	}

	public SuspectRequireRoleGC(List<RoleClassifications> _class, int _wanted = 1, bool _true_class = false, bool _lock_self = true)
	{
		if (_true_class)
		{
			is_target = (Roles _r) => _class.Contains(_r.getClassificationFromRoleType());
		}
		else
		{
			is_target = (Roles _r) => _class.Contains(_r.createEmptyRole().getVisualClassification());
		}
		roles_required = _wanted;
		lock_self = _lock_self;
		allow_suspect_ratio_increase = true;
		error_builder = new RequirementEEB(_class);
	}

	public SuspectRequireRoleGC(RoleGenerationMarkers _marker, int _wanted = 1, bool _lock_self = true)
	{
		Func<Roles, bool> func = (Roles _r) => _r.createEmptyRole().generation_constraint.isOfMarker(_marker);
		bool flag = _lock_self;
		EditorErrorBuilder editorErrorBuilder = new RequirementEEB(_marker);
		is_target = func;
		roles_required = _wanted;
		lock_self = flag;
		error_builder = editorErrorBuilder;
	}

	public SuspectRequireRoleGC(RoleClassifications _class, RoleGenerationMarkers _marker, int _wanted = 1, bool _true_class = false, bool _lock_self = true)
	{
		if (_true_class)
		{
			is_target = delegate(Roles _r)
			{
				RoleData roleData = _r.createEmptyRole();
				return roleData.role.getClassificationFromRoleType() == _class && roleData.generation_constraint.isOfMarker(_marker);
			};
		}
		else
		{
			is_target = delegate(Roles _r)
			{
				RoleData roleData2 = _r.createEmptyRole();
				return roleData2.getVisualClassification() == _class && roleData2.generation_constraint.isOfMarker(_marker);
			};
		}
		roles_required = _wanted;
		lock_self = _lock_self;
		allow_suspect_ratio_increase = true;
		error_builder = new RequirementEEB(_marker);
	}

	public SuspectRequireRoleGC(Func<Roles, bool> _contidion, EditorErrorBuilder _error_builder, int _wanted = 1, bool _lock_self = true)
	{
		bool flag = _lock_self;
		is_target = _contidion;
		roles_required = _wanted;
		lock_self = flag;
		error_builder = _error_builder;
	}

	public bool tryAddSuspect(Roles _role, bool _forced, List<Roles> _from, List<Marker<Roles>> _current_list, List<Roles> _available_roles, SuspectListFactory _factory)
	{
		int num = _current_list.Count((Marker<Roles> _m) => is_target(_m.data)) + _from.Count((Roles _r) => _r != _role && is_target(_r));
		if (num >= roles_required)
		{
			return true;
		}
		List<Roles> list = _available_roles.Where((Roles _r) => _r != _role && is_target(_r) && !_current_list.Any((Marker<Roles> _m) => _m.data == _r)).ToList();
		if (num + list.Count < roles_required)
		{
			return false;
		}
		if (list.Count == 1)
		{
			return _factory.externalTryAddSuspect(list[0], _from.copy().add(_role), _current_list, _available_roles, allow_suspect_ratio_increase, _forced, _locked: true);
		}
		return _factory.externalTryAddAnySuspect(list, _from.copy().add(_role), _current_list, _available_roles, allow_suspect_ratio_increase, _forced, _locked: true, roles_required - num);
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		return true;
	}

	public virtual List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, Roles _self, ClueTypes _self_type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_self_type == ClueTypes.ROLE_NOT_IN_PLAY)
		{
			return _roles;
		}
		if (_type.equalToAny(ClueTypes.ROLE_IN_PLAY, ClueTypes.ROLE_SUSPECTED))
		{
			return _roles;
		}
		int additional_from_forced = countTargetRoles(_forced.getOrCreate(ClueTypes.ROLE_SUSPECTED, () => new List<Roles>())) + countTargetRoles(_forced.getOrCreate(ClueTypes.ROLE_IN_PLAY, () => new List<Roles>()));
		return filterRolesIfRequired(_roles, _unforced, additional_from_forced);
	}

	public HashSet<Roles> addToLeadRoles(Roles _role, HashSet<Roles> _lead_roles, List<Roles> _potential, System.Random _rng)
	{
		int num = _lead_roles.Count((Roles _r) => is_target(_r));
		if (num >= roles_required)
		{
			return _lead_roles;
		}
		List<Roles> list = _potential.Where((Roles _r) => !_lead_roles.Contains(_r) && is_target(_r)).ToList();
		_lead_roles.addRange(list.getRandomElementsFromList(_rng, Mathf.Min(list.Count, roles_required - num)));
		return _lead_roles;
	}

	protected int countTargetRoles(List<Roles> _roles)
	{
		return _roles.Count((Roles _r) => is_target(_r));
	}

	protected List<Roles> filterRolesIfRequired(List<Roles> _roles, List<Roles> _lead_roles, int _additional_from_forced)
	{
		if (_additional_from_forced > roles_required)
		{
			return _roles;
		}
		List<Roles> list = _lead_roles.Where((Roles _r) => is_target(_r)).ToList();
		if (list.Count > roles_required)
		{
			return _roles;
		}
		return _roles.removeRange(list);
	}

	public virtual bool canBeAddedAsRoleClue(Roles _role, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_type == ClueTypes.ROLE_NOT_IN_PLAY)
		{
			return true;
		}
		int num = (is_target(_role) ? 1 : 0);
		return countTargetRoles(_unforced) + countTargetRoles(_forced.getOrCreate(ClueTypes.ROLE_SUSPECTED, () => new List<Roles>())) + countTargetRoles(_forced.getOrCreate(ClueTypes.ROLE_IN_PLAY, () => new List<Roles>())) >= roles_required + num;
	}

	public Maybe<ValidationError> checkSuspectListForError(CaseType _type, Roles _self, List<Roles> _suspect_list, CaseSnapshot _snap)
	{
		if (_suspect_list.Count((Roles _r) => _r != _self && is_target(_r)) >= roles_required)
		{
			return new Maybe<ValidationError>();
		}
		return error_builder.createValidationError(_self).maybe();
	}
}
