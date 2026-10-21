using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

public class AvoidInPlayRoleTypeGC : AdvancedGenerationConstraint, IInPlayListGenerationConstraint, IFilterRoleCluesGenerationConstraint
{
	private RoleGenerationMarkers to_avoid;

	private DisguiseConstraintType disguise;

	public AvoidInPlayRoleTypeGC(RoleGenerationMarkers _to_avoid, DisguiseConstraintType _disguise)
	{
		disguise = _disguise;
		to_avoid = _to_avoid;
	}

	public bool tryAddRoleInPlay(ChainMarker<Roles> _self, bool _forced, Maybe<ChainMarker<Roles>> _from, List<ChainMarker<Roles>> _current_list, List<Roles> _suspect_list, InPlayListFactory _factory)
	{
		if (_from.is_some && _from.value.existsFrom((Roles _r) => _factory.getEmptyRole(_r).generation_constraint.isOfMarker(to_avoid)))
		{
			return false;
		}
		if (_current_list.Any((ChainMarker<Roles> _r) => _factory.getEmptyRole(_r.data).generation_constraint.isOfMarker(to_avoid)))
		{
			return false;
		}
		_factory.externalAddVetoe(_suspect_list.Where((Roles _r) => _factory.getEmptyRole(_r).generation_constraint.isOfMarker(to_avoid)).ToList());
		return true;
	}

	public bool canReplaceRoleInPlay(RoleData _role, ChainMarker<Roles> _to_replace, Maybe<ChainMarker<Roles>> _self, InPlayListFactory _factory)
	{
		return !_role.generation_constraint.isOfMarker(to_avoid);
	}

	public Maybe<ValidationError> checkInPlayListForError(CaseType _type, Roles _self, List<Roles> _in_play_list, CaseSnapshot _snap)
	{
		Maybe<Roles> maybe = _in_play_list.firstIfSome((Roles _r) => _r.createEmptyRole().generation_constraint.isOfMarker(to_avoid));
		if (!maybe.is_some)
		{
			return new Maybe<ValidationError>();
		}
		return new ValidationError(LevelEditorHelper.inPlayAvoidRoleErrorLocalised(maybe.value), _self).maybe();
	}

	public List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, Roles _self, ClueTypes _self_type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_self_type == ClueTypes.ROLE_NOT_IN_PLAY || (_self_type == ClueTypes.ROLE_SUSPECTED && _type == ClueTypes.ROLE_NOT_IN_PLAY))
		{
			return _roles;
		}
		return _roles.Where((Roles _r) => !_r.createEmptyRole().generation_constraint.isOfMarker(to_avoid)).ToList();
	}

	public bool canBeAddedAsRoleClue(Roles _role, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_type == ClueTypes.ROLE_NOT_IN_PLAY)
		{
			return true;
		}
		if (!_forced.getOrCreate(ClueTypes.ROLE_IN_PLAY, () => new List<Roles>()).Any((Roles _r) => _r.createEmptyRole().generation_constraint.isOfMarker(to_avoid)))
		{
			return !_forced.getOrCreate(ClueTypes.ROLE_SUSPECTED, () => new List<Roles>()).Any((Roles _r) => _r.createEmptyRole().generation_constraint.isOfMarker(to_avoid));
		}
		return false;
	}

	public HashSet<Roles> addToLeadRoles(Roles _role, HashSet<Roles> _lead_roles, List<Roles> _potential, System.Random _rng)
	{
		return _lead_roles;
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		if (disguise == DisguiseConstraintType.ALWAYS_IGNORE || (disguise == DisguiseConstraintType.IGNORE_WHEN_LYING && _bad_info))
		{
			return true;
		}
		return !_board.getRolesInPlay().Any((KeyValuePair<int, RoleData> _i) => _i.Value.generation_constraint.isOfMarker(to_avoid));
	}
}
