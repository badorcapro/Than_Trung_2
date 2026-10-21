using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

namespace Quirks;

public class HiddenSmirk : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.HIDDEN_SMIRK;

	protected override string english_name => "Hidden Smirk";

	protected override string english_description => "The " + Roles.SCOUNDREL.toString() + " will now " + Keywords.LIE.toString() + " and " + Keywords.PRETEND.toString() + " to be a " + TextHelper.suspectedRole + ".";

	public override bool is_case_start_quirk => true;

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (_available_roles.Contains(Roles.SCOUNDREL))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		List<KeyValuePair<int, RoleData>> list = (from _r in _board.getRolesInPlay()
			where _r.Value.role == Roles.SCOUNDREL
			select _r).ToList();
		if (list.Count == 0)
		{
			return _board;
		}
		if (list.Count == 2)
		{
			Debug.LogError($"Several scoundrels in play??!? {quirk_type}");
		}
		list[0].Value.setLying(_new: true);
		list[0].Value.setDisguiseCharacteristics(CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED));
		return _board;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return canRoleAppearInPlay(Roles.SCOUNDREL, _unforced, _forced);
	}
}
