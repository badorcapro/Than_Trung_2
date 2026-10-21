using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

public class AvoidInPlayRoleGC : AdvancedGenerationConstraint, IInPlayListGenerationConstraint, IFilterRoleCluesGenerationConstraint
{
	private Roles[] roles_to_avoid;

	private DisguiseConstraintType disguise;

	public AvoidInPlayRoleGC(DisguiseConstraintType _disguise, params Roles[] _to_avoid)
	{
		disguise = _disguise;
		roles_to_avoid = _to_avoid;
	}

	public bool tryAddRoleInPlay(ChainMarker<Roles> _self, bool _forced, Maybe<ChainMarker<Roles>> _from, List<ChainMarker<Roles>> _current_list, List<Roles> _suspect_list, InPlayListFactory _factory)
	{
		if (_from.is_some && _from.value.existsFrom((Roles _r) => roles_to_avoid.Contains(_r)))
		{
			return false;
		}
		if (_current_list.Any((ChainMarker<Roles> _r) => roles_to_avoid.Contains(_r.data)))
		{
			return false;
		}
		_factory.externalAddVetoe(roles_to_avoid.ToList());
		return true;
	}

	public bool canReplaceRoleInPlay(RoleData _role, ChainMarker<Roles> _to_replace, Maybe<ChainMarker<Roles>> _self, InPlayListFactory _factory)
	{
		return !roles_to_avoid.Contains(_role.role);
	}

	public Maybe<ValidationError> checkInPlayListForError(CaseType _type, Roles _self, List<Roles> _in_play_list, CaseSnapshot _snap)
	{
		Maybe<Roles> maybe = _in_play_list.firstIfSome((Roles _r) => roles_to_avoid.Contains(_r));
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
		return _roles.removeRange(roles_to_avoid);
	}

	public bool canBeAddedAsRoleClue(Roles _role, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_type == ClueTypes.ROLE_NOT_IN_PLAY)
		{
			return true;
		}
		return !roles_to_avoid.Any((Roles _r) => _forced.getOrCreate(ClueTypes.ROLE_IN_PLAY, () => new List<Roles>()).Contains(_r) || _forced.getOrCreate(ClueTypes.ROLE_SUSPECTED, () => new List<Roles>()).Contains(_r));
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
		return !_board.getRolesInPlay().Any((KeyValuePair<int, RoleData> _i) => roles_to_avoid.Contains(_i.Value.role));
	}
}
