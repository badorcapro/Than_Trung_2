using System;
using System.Collections.Generic;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

public class TransformToRoleGC : AdvancedGenerationConstraint, ITransformationGenerationConstraint, IFilterRoleCluesGenerationConstraint, ISuspectListGenerationConstraint, IModifyEditorRatio
{
	protected Func<Roles, bool> is_target_for_transformation;

	protected Func<Dictionary<RoleClassifications, int>> class_modification;

	protected Roles to_add;

	public bool lock_self_suspect => true;

	public TransformToRoleGC(RoleClassifications _to_transfrom, Roles _transform_to)
	{
		Func<Roles, bool> func = (Roles _r) => _r.getClassificationFromRoleType() == _to_transfrom;
		Func<Dictionary<RoleClassifications, int>> editorModification = getEditorModification(_to_transfrom, _transform_to);
		is_target_for_transformation = func;
		class_modification = editorModification;
		to_add = _transform_to;
	}

	private Func<Dictionary<RoleClassifications, int>> getEditorModification(RoleClassifications _trans, Roles _to)
	{
		return () => new Dictionary<RoleClassifications, int>
		{
			{ _trans, 1 },
			{
				_to.getClassificationFromRoleType(),
				-1
			}
		};
	}

	public bool tryAddSuspect(Roles _role, bool _forced, List<Roles> _from, List<Marker<Roles>> _current_list, List<Roles> _available_roles, SuspectListFactory _factory)
	{
		if (!_factory.forced_not_suspected.Contains(to_add))
		{
			return AvoidSuspectRoleGC.avoidSuspect(_forced, _from, _factory.forced_suspected, _current_list, _available_roles, to_add);
		}
		return false;
	}

	public bool tryTransformation(List<ChainMarker<Roles>> _can_transform, List<ChainMarker<Roles>> _in_play_roles, System.Random _rng, InPlayListFactory _factory, out Maybe<(ChainMarker<Roles>, Roles)> _to_transform)
	{
		Maybe<ChainMarker<Roles>> maybe = _can_transform.firstIfSome((ChainMarker<Roles> _m) => is_target_for_transformation(_m.data) && (!_m.from.is_some || _factory.getEmptyRole(_m.from.value.data).generation_constraint.canReplaceInPlayRole(_factory.getEmptyRole(to_add), _m, new Maybe<ChainMarker<Roles>>(), _factory)));
		if (!maybe.is_some)
		{
			_to_transform = new Maybe<(ChainMarker<Roles>, Roles)>();
			return false;
		}
		_to_transform = (maybe.value, to_add).maybe();
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
		return _roles.remove(to_add);
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
		return _unforced.Contains(to_add);
	}

	public Maybe<Roles> getRoleTransformed(Roles _self, CaseSnapshot _snap)
	{
		return to_add.maybe();
	}

	public Maybe<ValidationError> checkSuspectListForError(CaseType _type, Roles _self, List<Roles> _suspect_list, CaseSnapshot _snap)
	{
		return new Maybe<ValidationError>();
	}

	public Maybe<ValidationError> checkTransformationError(CaseType _type, Roles _self, List<Roles> _in_play, CaseSnapshot _snap)
	{
		if (_in_play.Contains(to_add))
		{
			return new Maybe<ValidationError>();
		}
		return new RequirementEEB(to_add).createValidationError(_self).maybe();
	}

	public Dictionary<RoleClassifications, int> getModification()
	{
		return class_modification();
	}
}
