using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Maybe;
using UnityEngine;

public class InPlayRequireRoleGC : SuspectRequireRoleGC, IInPlayListGenerationConstraint
{
	protected DisguiseConstraintType disguise_constraint;

	public InPlayRequireRoleGC(Roles _role, DisguiseConstraintType _disguise = DisguiseConstraintType.IGNORE_WHEN_LYING, bool _lock_self = true)
		: base(_role, _lock_self)
	{
		disguise_constraint = _disguise;
	}

	public InPlayRequireRoleGC(RoleClassifications _class, int _wanted = 1, bool _true_class = false, DisguiseConstraintType _disguise = DisguiseConstraintType.IGNORE_WHEN_LYING, bool _lock_self = true)
		: base(_class, _wanted, _true_class, _lock_self)
	{
		disguise_constraint = _disguise;
	}

	public InPlayRequireRoleGC(List<RoleClassifications> _class, int _wanted = 1, bool _true_class = false, DisguiseConstraintType _disguise = DisguiseConstraintType.IGNORE_WHEN_LYING, bool _lock_self = true)
		: base(_class, _wanted, _true_class, _lock_self)
	{
		disguise_constraint = _disguise;
	}

	public InPlayRequireRoleGC(RoleGenerationMarkers _marker, int _wanted = 1, DisguiseConstraintType _disguise = DisguiseConstraintType.IGNORE_WHEN_LYING, bool _lock_self = true)
		: base(_marker, _wanted, _lock_self)
	{
		disguise_constraint = _disguise;
	}

	public InPlayRequireRoleGC(RoleClassifications _class, RoleGenerationMarkers _marker, int _wanted = 1, bool _true_class = false, DisguiseConstraintType _disguise = DisguiseConstraintType.IGNORE_WHEN_LYING, bool _lock_self = true)
		: base(_class, _marker, _wanted, _true_class, _lock_self)
	{
		disguise_constraint = _disguise;
	}

	public InPlayRequireRoleGC(Func<Roles, bool> _condition, EditorErrorBuilder _error_builder, int _wanted = 1, DisguiseConstraintType _disguise = DisguiseConstraintType.IGNORE_WHEN_LYING, bool _lock_self = true)
		: base(_condition, _error_builder, _wanted, _lock_self)
	{
		disguise_constraint = _disguise;
	}

	public bool canReplaceRoleInPlay(RoleData _role, ChainMarker<Roles> _to_replace, Maybe<ChainMarker<Roles>> _self, InPlayListFactory _factory)
	{
		return is_target(_role.role);
	}

	public bool tryAddRoleInPlay(ChainMarker<Roles> _self, bool _forced, Maybe<ChainMarker<Roles>> _from, List<ChainMarker<Roles>> _current_list, List<Roles> _suspect_list, InPlayListFactory _factory)
	{
		int num = _current_list.Count((ChainMarker<Roles> _m) => is_target(_m.data));
		if (_from.is_some)
		{
			num += _from.value.fromCount(is_target);
		}
		if (num >= roles_required)
		{
			return true;
		}
		List<Roles> list = _suspect_list.Where((Roles _r) => _r != _self.data && is_target(_r)).ToList();
		if (num + list.Count < roles_required)
		{
			return false;
		}
		if (list.Count == 1)
		{
			return _factory.externalTryAddRole(list[0], _self, _suspect_list, _forced);
		}
		return _factory.externalTryAddAnyOfRoles(list, _self, _suspect_list, _forced, roles_required - num);
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		if (!requireFurtherCheck(disguise_constraint, _bad_info))
		{
			return true;
		}
		return _board.getRolesInPlay().Count((KeyValuePair<int, RoleData> _kvp) => is_target(_kvp.Value.role)) >= roles_required;
	}

	public Maybe<ValidationError> checkInPlayListForError(CaseType _type, Roles _self, List<Roles> _in_play_list, CaseSnapshot _snap)
	{
		if (_in_play_list.Count((Roles _r) => _r != _self && is_target(_r)) >= roles_required)
		{
			return new Maybe<ValidationError>();
		}
		return error_builder.createValidationError(_self).maybe();
	}

	protected List<RoleData> getTargetableSuspects(CaseSnapshot _snap, List<Roles> _in_play_list)
	{
		return _snap.true_suspect_list.Where((RoleData _r) => !_in_play_list.Contains(_r.role) && is_target(_r.role)).ToList();
	}
}
