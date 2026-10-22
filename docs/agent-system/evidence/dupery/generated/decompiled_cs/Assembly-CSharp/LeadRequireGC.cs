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

public class LeadRequireGC : AdvancedGenerationConstraint, IFilterRoleCluesGenerationConstraint
{
	protected int roles_required = 1;

	protected Func<Roles, bool> is_target;

	public LeadRequireGC(Roles _role)
	{
		Func<Roles, bool> func = (Roles _r) => _r == _role;
		is_target = func;
		roles_required = 1;
	}

	public LeadRequireGC(RoleGenerationMarkers _marker, int _wanted = 1)
	{
		Func<Roles, bool> func = (Roles _r) => _r.createEmptyRole().generation_constraint.isOfMarker(_marker);
		is_target = func;
		roles_required = _wanted;
	}

	public LeadRequireGC(RoleClassifications _class, RoleGenerationMarkers _marker, int _wanted = 1, bool _true_class = true)
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
	}

	public LeadRequireGC(List<RoleClassifications> _class, RoleGenerationMarkers _marker, int _wanted = 1, bool _true_class = true)
	{
		if (_true_class)
		{
			is_target = delegate(Roles _r)
			{
				RoleData roleData = _r.createEmptyRole();
				return _class.Contains(roleData.role.getClassificationFromRoleType()) && roleData.generation_constraint.isOfMarker(_marker);
			};
		}
		else
		{
			is_target = delegate(Roles _r)
			{
				RoleData roleData2 = _r.createEmptyRole();
				return _class.Contains(roleData2.getVisualClassification()) && roleData2.generation_constraint.isOfMarker(_marker);
			};
		}
		roles_required = _wanted;
	}

	public LeadRequireGC(Func<Roles, bool> _contidion, int _wanted = 1)
	{
		is_target = _contidion;
		roles_required = _wanted;
	}

	public bool canBeAddedAsRoleClue(Roles _role, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_type == ClueTypes.ROLE_NOT_IN_PLAY)
		{
			return true;
		}
		return hasEnough(_role, _unforced, _forced);
	}

	public List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, Roles _self, ClueTypes _self_type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_type.equalToAny(ClueTypes.ROLE_IN_PLAY, ClueTypes.ROLE_SUSPECTED) || hasEnough(_self, _unforced, _forced))
		{
			return _roles;
		}
		_roles.RemoveAll((Roles _r) => is_target(_r));
		return _roles;
	}

	private bool hasEnough(Roles _self, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		int num = _unforced.Count((Roles _r) => _r != _self && is_target(_r));
		if (num >= roles_required)
		{
			return true;
		}
		num += _forced.getOrCreate(ClueTypes.ROLE_IN_PLAY, () => new List<Roles>()).Count((Roles _r) => _r != _self && is_target(_r));
		if (num >= roles_required)
		{
			return true;
		}
		num += _forced.getOrCreate(ClueTypes.ROLE_IN_PLAY, () => new List<Roles>()).Count((Roles _r) => _r != _self && is_target(_r));
		return num >= roles_required;
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		return true;
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
}
