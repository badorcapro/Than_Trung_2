using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using UnityEngine;

namespace Quirks;

public class AntiAuthoritarianism : CaseQuirkData
{
	public override CaseQuirks quirk_type => CaseQuirks.ANTI_AUTHORITARIANISM;

	protected override string english_name => "Anti-Authoritarianism";

	protected override string english_description => "If your " + Keywords.REPUTATION_STATUS.toString() + " is not " + ReputationStatus.EXCEPTIONAL.toString() + ", 2 " + TextHelper.innocentRoles + " become " + TextHelper.tainted + " if possible.";

	public override bool is_case_start_quirk => true;

	public override bool isCompatible(CaseType _case_type)
	{
		return _case_type switch
		{
			CaseType.CLOCK => true, 
			CaseType.DOCKS => true, 
			_ => false, 
		};
	}

	public override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onCaseStart(Case _case, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		if (_case is ClockCase clockCase)
		{
			if (clockCase.reputation <= 4)
			{
				applyEffect(_board, _rng);
			}
			return _board;
		}
		if (_case is DocksCase docksCase)
		{
			if (docksCase.reputation <= 4)
			{
				applyEffect(_board, _rng);
			}
			return _board;
		}
		Debug.LogError($"{quirk_type} onCaseStart is not set up for this region! {_case.case_type}");
		return _board;
	}

	private void applyEffect(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, System.Random _rng)
	{
		List<KeyValuePair<int, RoleData>> list = (from _r in _board.getRolesInPlay()
			where _r.Value.getVisualClassification() == RoleClassifications.INNOCENT
			select _r).ToList();
		list.getRandomElementsFromList(_rng, Mathf.Min(2, list.Count)).ForEach(delegate(KeyValuePair<int, RoleData> _r)
		{
			_r.Value.setTainted(_new: true);
		});
	}
}
