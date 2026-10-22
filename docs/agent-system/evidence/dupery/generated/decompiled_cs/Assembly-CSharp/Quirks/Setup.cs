using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

namespace Quirks;

public class Setup : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.SETUP;

	protected override string english_name => "Setup";

	protected override string english_description => "The " + Roles.FALL_GUY.toString() + " will now " + Keywords.PRETEND.toString() + " to be a " + TextHelper.inPlayInnocentRole + ".";

	public override bool is_case_start_quirk => true;

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (_available_roles.Contains(Roles.FALL_GUY))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		List<KeyValuePair<int, RoleData>> list = (from _r in _board.getRolesInPlay()
			where _r.Value.role == Roles.FALL_GUY
			select _r).ToList();
		if (list.Count == 0)
		{
			return _board;
		}
		list[0].Value.setDisguiseCharacteristics(CaseHelper.getInnocentDisguise(DisguiseTarget.IN_PLAY));
		return _board;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return canRoleAppearInPlay(Roles.FALL_GUY, _unforced, _forced);
	}
}
