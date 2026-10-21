using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

public class AvoidSuspectTypeGC : AdvancedGenerationConstraint, ISuspectListGenerationConstraint, IFilterRoleCluesGenerationConstraint
{
	protected Func<Roles, bool> avoid;

	public bool lock_self_suspect => true;

	public AvoidSuspectTypeGC(RoleGenerationMarkers _marker)
	{
		avoid = (Roles _r) => _r.createEmptyRole().generation_constraint.isOfMarker(_marker);
	}

	public AvoidSuspectTypeGC(Func<Roles, bool> _avoid)
	{
		avoid = _avoid;
	}

	public bool tryAddSuspect(Roles _role, bool _forced, List<Roles> _from, List<Marker<Roles>> _current_list, List<Roles> _available_roles, SuspectListFactory _factory)
	{
		if (_from.Any((Roles _r) => avoid(_r)) || _factory.forced_suspected.Any((Roles _r) => avoid(_r)))
		{
			return false;
		}
		if (_forced)
		{
			if (_current_list.Any((Marker<Roles> _m) => _m.locked && avoid(_m.data)))
			{
				return false;
			}
			_current_list.removeAll((Marker<Roles> _m) => avoid(_m.data));
		}
		else if (_current_list.Any((Marker<Roles> _r) => avoid(_r.data)))
		{
			return false;
		}
		_available_roles.removeAll((Roles _r) => avoid(_r));
		return true;
	}

	public bool canBeAddedAsRoleClue(Roles _role, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_type == ClueTypes.ROLE_NOT_IN_PLAY)
		{
			return true;
		}
		if (!_forced.getOrCreate(ClueTypes.ROLE_IN_PLAY, () => new List<Roles>()).Any((Roles _r) => avoid(_r)))
		{
			return !_forced.getOrCreate(ClueTypes.ROLE_SUSPECTED, () => new List<Roles>()).Any((Roles _r) => avoid(_r));
		}
		return false;
	}

	public List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, Roles _self, ClueTypes _self_type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_self_type == ClueTypes.ROLE_NOT_IN_PLAY || _type == ClueTypes.ROLE_NOT_IN_PLAY)
		{
			return _roles;
		}
		return _roles.Where((Roles _r) => !avoid(_r)).ToList();
	}

	public HashSet<Roles> addToLeadRoles(Roles _role, HashSet<Roles> _lead_roles, List<Roles> _potential, System.Random _rng)
	{
		return _lead_roles;
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		return true;
	}

	public Maybe<ValidationError> checkSuspectListForError(CaseType _type, Roles _self, List<Roles> _suspect_list, CaseSnapshot _snap)
	{
		Maybe<Roles> maybe = _suspect_list.firstIfSome((Roles _r) => _r != _self && avoid(_r));
		if (!maybe.is_some)
		{
			return new Maybe<ValidationError>();
		}
		return new ValidationError(LevelEditorHelper.suspectAvoidRoleErrorLocalised(maybe.value), _self).maybe();
	}
}
