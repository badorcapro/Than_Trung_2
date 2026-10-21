using System.Collections.Generic;
using CaseCreation;
using GRGLib.Maybe;
using UnityEngine;

public class InPlayLocationGC : AdvancedGenerationConstraint, IInPlayListGenerationConstraint, IAddLocationGenerationConstraint
{
	protected LocationTypes location_to_add;

	protected DisguiseConstraintType disguise_constraint;

	protected EditorErrorBuilder error_builder;

	public InPlayLocationGC(LocationTypes _loc, DisguiseConstraintType _disguise_constraint)
	{
		EditorErrorBuilder editorErrorBuilder = new RequirementEEB(_loc);
		location_to_add = _loc;
		disguise_constraint = _disguise_constraint;
		error_builder = editorErrorBuilder;
	}

	public virtual bool canReplaceRoleInPlay(RoleData _role, ChainMarker<Roles> _to_replace, Maybe<ChainMarker<Roles>> _self, InPlayListFactory _factory)
	{
		return true;
	}

	public virtual bool tryAddRoleInPlay(ChainMarker<Roles> _self, bool _forced, Maybe<ChainMarker<Roles>> _from, List<ChainMarker<Roles>> _current_list, List<Roles> _suspect_list, InPlayListFactory _factory)
	{
		if (_factory.externalAddLocation(location_to_add, _self))
		{
			_self.locked = true;
			return true;
		}
		return false;
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		if (!requireFurtherCheck(disguise_constraint, _bad_info))
		{
			return true;
		}
		return _board.getLocationsInPlay().ContainsKey(location_to_add);
	}

	public Maybe<ValidationError> checkInPlayListForError(CaseType _type, Roles _self, List<Roles> _in_play_list, CaseSnapshot _snap)
	{
		if (_snap.board.getLocationsInPlay().ContainsKey(location_to_add))
		{
			return new Maybe<ValidationError>();
		}
		return error_builder.createValidationError(_self).maybe();
	}

	public Maybe<LocationTypes> getForcedLocation(bool _is_force_suspected, bool _is_force_in_play)
	{
		if (!_is_force_in_play)
		{
			return new Maybe<LocationTypes>();
		}
		return location_to_add.maybe();
	}
}
