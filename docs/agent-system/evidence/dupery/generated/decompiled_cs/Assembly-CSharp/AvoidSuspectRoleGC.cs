using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

public class AvoidSuspectRoleGC : AdvancedGenerationConstraint, ISuspectListGenerationConstraint, IFilterRoleCluesGenerationConstraint
{
	private Roles[] roles_to_avoid;

	public bool lock_self_suspect => true;

	public AvoidSuspectRoleGC(params Roles[] _to_avoid)
	{
		roles_to_avoid = _to_avoid;
	}

	public bool tryAddSuspect(Roles _role, bool _forced, List<Roles> _from, List<Marker<Roles>> _current_list, List<Roles> _available_roles, SuspectListFactory _factory)
	{
		return avoidSuspect(_forced, _from, _factory.forced_suspected, _current_list, _available_roles, roles_to_avoid);
	}

	public static bool avoidSuspect(bool _forced, List<Roles> _from, List<Roles> _force_suspected, List<Marker<Roles>> _current_list, List<Roles> _available_roles, params Roles[] _to_avoid)
	{
		if (_to_avoid.Any((Roles _r) => _from.Contains(_r) || _force_suspected.Contains(_r)))
		{
			return false;
		}
		if (_forced)
		{
			if (_current_list.Any((Marker<Roles> _m) => _m.locked && _to_avoid.Contains(_m.data)))
			{
				return false;
			}
			_current_list.removeAll((Marker<Roles> _m) => _to_avoid.Contains(_m.data));
		}
		else if (_to_avoid.Any((Roles _r) => _current_list.Any((Marker<Roles> _m) => _m.data == _r)))
		{
			return false;
		}
		_available_roles.removeRange(_to_avoid);
		return true;
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		return true;
	}

	public List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, Roles _self, ClueTypes _self_type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_self_type == ClueTypes.ROLE_NOT_IN_PLAY)
		{
			return _roles;
		}
		return _roles.removeRange(roles_to_avoid);
	}

	public HashSet<Roles> addToLeadRoles(Roles _role, HashSet<Roles> _lead_roles, List<Roles> _potential, System.Random _rng)
	{
		return _lead_roles;
	}

	public bool canBeAddedAsRoleClue(Roles _role, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_type == ClueTypes.ROLE_NOT_IN_PLAY)
		{
			return true;
		}
		return !roles_to_avoid.Any((Roles _r) => _forced.getOrCreate(ClueTypes.ROLE_IN_PLAY, () => new List<Roles>()).Contains(_r) || _forced.getOrCreate(ClueTypes.ROLE_SUSPECTED, () => new List<Roles>()).Contains(_r));
	}

	public Maybe<ValidationError> checkSuspectListForError(CaseType _type, Roles _self, List<Roles> _suspect_list, CaseSnapshot _snap)
	{
		Maybe<Roles> maybe = _suspect_list.firstIfSome((Roles _r) => roles_to_avoid.Contains(_r));
		if (!maybe.is_some)
		{
			return new Maybe<ValidationError>();
		}
		return new ValidationError(LevelEditorHelper.suspectAvoidRoleErrorLocalised(maybe.value), _self).maybe();
	}
}
