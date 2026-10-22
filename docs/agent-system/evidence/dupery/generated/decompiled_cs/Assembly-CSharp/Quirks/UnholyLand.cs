using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

namespace Quirks;

public class UnholyLand : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.UNHOLY_LAND;

	protected override string english_name => "Unholy Land";

	protected override string english_description => "The " + Roles.PRIEST.toString() + " will " + Keywords.LIE.toString() + " and " + Keywords.PRETEND.toString() + " to be a " + Roles.SKEPTIC.toString() + ".";

	public override bool is_suspect_addition_quirk => true;

	public override bool is_case_start_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.CLOCK;
	}

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (_available_roles.Contains(Roles.PRIEST))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override Maybe<Roles> onSuspectAddition(Roles _adding, bool _force, List<Roles> _from)
	{
		if (_adding == Roles.PRIEST)
		{
			return Roles.SKEPTIC.maybe();
		}
		return new Maybe<Roles>();
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		List<KeyValuePair<int, RoleData>> list = (from _r in _board.getRolesInPlay()
			where _r.Value.role == Roles.PRIEST
			select _r).ToList();
		if (list.Count == 0)
		{
			return _board;
		}
		list[0].Value.setLying(_new: true);
		list[0].Value.setDisguiseCharacteristics(new DisguiseCharacteristics(Roles.SKEPTIC));
		return _board;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (canRoleAppearInPlay(Roles.PRIEST, _unforced, _forced) && canRoleAppearInPlay(Roles.SKEPTIC, _unforced, _forced))
		{
			return !_quirks.Contains(CaseQuirks.BREACH_OF_TRUST);
		}
		return false;
	}

	public override List<Roles> filterRoleForClues(List<Roles> _roles, ClueTypes _type, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (_type != ClueTypes.ROLE_NOT_IN_PLAY)
		{
			return _roles;
		}
		_roles.Remove(Roles.SKEPTIC);
		return _roles;
	}
}
