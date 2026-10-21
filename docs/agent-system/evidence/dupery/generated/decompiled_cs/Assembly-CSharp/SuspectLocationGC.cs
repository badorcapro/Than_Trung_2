using System.Collections.Generic;
using CaseCreation;
using GRGLib.Maybe;
using UnityEngine;

public class SuspectLocationGC : AdvancedGenerationConstraint, ISuspectListGenerationConstraint, IAddLocationGenerationConstraint
{
	public LocationTypes location_to_add { get; private set; }

	public bool lock_self_suspect => true;

	public SuspectLocationGC(LocationTypes _loc)
	{
		location_to_add = _loc;
	}

	public bool tryAddSuspect(Roles _role, bool _forced, List<Roles> _from, List<Marker<Roles>> _current_list, List<Roles> _available_roles, SuspectListFactory _factory)
	{
		return _factory.externalAddLocation(location_to_add, _locked: true);
	}

	public override bool validateDisguise(RoleData _role, Vector2Int _board_size, bool _bad_info, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, List<RoleData> _suspects)
	{
		return true;
	}

	public Maybe<ValidationError> checkSuspectListForError(CaseType _type, Roles _self, List<Roles> _suspect_list, CaseSnapshot _snap)
	{
		if (_snap.board.getLocationsInPlay().ContainsKey(location_to_add))
		{
			return new Maybe<ValidationError>();
		}
		return new RequirementEEB(location_to_add).createValidationError(_self).maybe();
	}

	public Maybe<LocationTypes> getForcedLocation(bool _is_force_suspected, bool _is_force_in_play)
	{
		if (!_is_force_suspected && !_is_force_in_play)
		{
			return new Maybe<LocationTypes>();
		}
		return location_to_add.maybe();
	}
}
