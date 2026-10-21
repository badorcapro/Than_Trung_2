using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

public class RoleGenerationConstraints
{
	public HashSet<RoleGenerationMarkers> role_gen_markers = new HashSet<RoleGenerationMarkers>();

	public List<AdvancedGenerationConstraint> advanced_constraints = new List<AdvancedGenerationConstraint>();

	public RoleGenerationConstraints()
	{
	}

	public RoleGenerationConstraints(AdvancedGenerationConstraint _constraint)
	{
		advanced_constraints = _constraint.makeListFromItem();
	}

	public RoleGenerationConstraints(RoleGenerationMarkers _marker, AdvancedGenerationConstraint _constraint)
		: this(_constraint)
	{
		role_gen_markers = new HashSet<RoleGenerationMarkers> { _marker };
	}

	public RoleGenerationConstraints(List<AdvancedGenerationConstraint> _constraints)
	{
		advanced_constraints = _constraints;
	}

	public RoleGenerationConstraints(RoleGenerationMarkers _marker, List<AdvancedGenerationConstraint> _constraints)
		: this(_constraints)
	{
		role_gen_markers = new HashSet<RoleGenerationMarkers> { _marker };
	}

	public RoleGenerationConstraints(params RoleGenerationMarkers[] _markers)
	{
		role_gen_markers = _markers.toHashSet();
	}

	public RoleGenerationConstraints(HashSet<RoleGenerationMarkers> _markers)
	{
		role_gen_markers = _markers;
	}

	public RoleGenerationConstraints addMarker(RoleGenerationMarkers _marker)
	{
		role_gen_markers.Add(_marker);
		return this;
	}

	public bool isOfMarker(RoleGenerationMarkers _marker)
	{
		return role_gen_markers.Contains(_marker);
	}

	public bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		return advanced_constraints.All((AdvancedGenerationConstraint _c) => _c.validateDisguise(_role, _board_size, _bad_info, _board, _suspects));
	}

	public bool canReplaceInPlayRole(RoleData _role, ChainMarker<Roles> _to_replace, Maybe<ChainMarker<Roles>> _self, InPlayListFactory _factory)
	{
		return getConstraintOfInterface<IInPlayListGenerationConstraint>().All((IInPlayListGenerationConstraint _ac) => _ac.canReplaceRoleInPlay(_role, _to_replace, _self, _factory));
	}

	public List<T> getConstraintOfInterface<T>()
	{
		return advanced_constraints.whereSelect((AdvancedGenerationConstraint _c) => _c is T, (AdvancedGenerationConstraint _c) => (T)(object)_c);
	}

	public List<Roles> filterRoleCluePossibilities(List<Roles> _roles, ClueTypes _type, RoleClue _self, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return filterRoleCluePossibilities(_roles, _type, _self.role_in_focus, _self.clue_type, _unforced, _forced);
	}

	public List<Roles> filterRoleCluePossibilities(List<Roles> _roles, ClueTypes _type, Roles _self, ClueTypes _self_type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		_roles.Remove(_self);
		return getConstraintOfInterface<IFilterRoleCluesGenerationConstraint>().Aggregate(_roles, (List<Roles> _a, IFilterRoleCluesGenerationConstraint _c) => _c.filterRoleForClues(_a, _type, _self, _self_type, _unforced, _forced));
	}

	public bool canBeAddedAsRoleClue(Roles _role, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_type != ClueTypes.ROLE_NOT_IN_PLAY && isOfMarker(RoleGenerationMarkers.SELF_CONFIRM) && (_forced.getOrCreate(ClueTypes.ROLE_IN_PLAY, () => new List<Roles>()).Any((Roles _r) => _r.createEmptyRole().generation_constraint.isOfMarker(RoleGenerationMarkers.SELF_CONFIRM)) || _forced.getOrCreate(ClueTypes.ROLE_SUSPECTED, () => new List<Roles>()).Any((Roles _r) => _r.createEmptyRole().generation_constraint.isOfMarker(RoleGenerationMarkers.SELF_CONFIRM))))
		{
			return false;
		}
		return getConstraintOfInterface<IFilterRoleCluesGenerationConstraint>().All((IFilterRoleCluesGenerationConstraint _gc) => _gc.canBeAddedAsRoleClue(_role, _type, _unforced, _forced));
	}
}
