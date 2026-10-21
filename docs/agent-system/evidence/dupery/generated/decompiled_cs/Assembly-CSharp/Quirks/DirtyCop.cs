using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

namespace Quirks;

public class DirtyCop : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.DIRTY_COP;

	protected override string english_name => "Dirty Cop";

	protected override string english_description => "The " + Roles.PARTNER.toString() + " is " + TextHelper.tainted + " if any of their " + TextHelper.surroundingNeighbours + " are " + Alignments.EVIL.toString() + ".";

	public override string description_white => base.description.colourSpriteLink("surrounding", Color.white);

	public override bool is_case_start_quirk => true;

	public override bool canAdd(List<Roles> _available_roles, List<CaseQuirks> _in_play_quirks, CaseType _case_type)
	{
		if (_available_roles.Contains(Roles.PARTNER))
		{
			return base.canAdd(_available_roles, _in_play_quirks, _case_type);
		}
		return false;
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		List<KeyValuePair<int, RoleData>> list = (from _r in _board.getRolesInPlay()
			where _r.Value.role == Roles.PARTNER
			select _r).ToList();
		if (list.Count == 0)
		{
			return _board;
		}
		if (list.Count == 2)
		{
			Debug.LogError($"Several partners in play??!? {quirk_type}");
		}
		if (_board.getSurroundingRolesFromGridPos(list[0].Value.getBoardPosition(), _case.board_size).Any((RoleData _r) => _r.getVisualAlignment() == Alignments.EVIL))
		{
			list[0].Value.setTainted(_new: true);
		}
		return _board;
	}

	public override bool isValidForClue(List<CaseQuirks> _quirks, List<Roles> _unforced, Dictionary<ClueTypes, List<Roles>> _forced)
	{
		return canRoleAppearInPlay(Roles.PARTNER, _unforced, _forced);
	}
}
