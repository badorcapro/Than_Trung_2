using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

namespace Quirks;

public class Jealousy : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.JEALOUSY;

	protected override string english_name => "Jealousy";

	protected override string english_description => "The " + Roles.ROMANTIC.toString() + " becomes " + Alignments.EVIL.toString() + " if the " + Roles.CASANOVA.toString() + " is " + Keywords.IN_PLAY.toString() + ".";

	public override bool is_case_start_quirk => true;

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (_available_roles.Contains(Roles.ROMANTIC) && _available_roles.Contains(Roles.CASANOVA))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		Dictionary<int, RoleData> rolesInPlay = _board.getRolesInPlay();
		List<KeyValuePair<int, RoleData>> list = rolesInPlay.Where((KeyValuePair<int, RoleData> _r) => _r.Value.role == Roles.ROMANTIC).ToList();
		if (list.Count == 0)
		{
			return _board;
		}
		if (rolesInPlay.Where((KeyValuePair<int, RoleData> _r) => _r.Value.role == Roles.CASANOVA).ToList().Count == 0)
		{
			return _board;
		}
		list[0].Value.setAlignment(Alignments.EVIL);
		return _board;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		if (canRoleAppearInPlay(Roles.CASANOVA, _unforced, _forced))
		{
			return canRoleAppearInPlay(Roles.ROMANTIC, _unforced, _forced);
		}
		return false;
	}
}
