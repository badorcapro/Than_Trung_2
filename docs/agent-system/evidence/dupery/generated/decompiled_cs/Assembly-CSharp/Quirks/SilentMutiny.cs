using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Leads;
using UnityEngine;

namespace Quirks;

public class SilentMutiny : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.SILENT_MUTINY;

	protected override string english_name => "Silent Mutiny";

	protected override string english_description => "The " + Roles.MUTINEER.toString() + " will now " + Keywords.LIE.toString() + " and " + Keywords.PRETEND.toString() + " to be a " + TextHelper.suspectedRole + ". They will only move the " + Keywords.BOAT.toString() + " and " + Keywords.REVEAL.toString() + " themselves, the first time it is moved onto them.";

	public override string credit => "Exiliado89";

	public override bool is_case_start_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type == CaseType.DOCKS;
	}

	public SilentMutiny(bool _completed)
	{
		base.quirk_completed = _completed;
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		List<KeyValuePair<int, RoleData>> list = (from _r in _board.getRolesInPlay()
			where _r.Value.role == Roles.MUTINEER
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
		return canRoleAppearInPlay(Roles.MUTINEER, _unforced, _forced);
	}

	public void setCompleted()
	{
		base.quirk_completed = true;
	}
}
