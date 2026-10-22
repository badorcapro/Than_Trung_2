using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class BigBlind : CasinoRoleData
{
	private const int investigation_extra_cost = 2;

	public override Roles role => Roles.BIG_BLIND;

	public override string english_name => "Big Blind";

	public override string english_description => string.Format("{0} cost an additional {1} {2} while I am {3}, {4}.", "Investigations".asKeyword(Keywords.INVESTIGATE), 2, TextHelper.chips_with_link, TextHelper.investigated, TextHelper.aliveAndNotArrested);

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)>
	{
		(DescriptionType.SPECIAL, "I do not increase the cost of " + TextHelper.investigating + " me."),
		(DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I do not increase the cost of " + "investigations".asKeyword(Keywords.INVESTIGATE) + ".")
	};

	public override string credits => "weeaboovoid";

	public override bool hasInfo => false;

	public BigBlind(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public BigBlind(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		return "";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		if (!base.investigated || base.has_bad_info || base.dead || base.arrested || _investigated_address == base.address)
		{
			return _board;
		}
		base.casino_case.spendChips(2);
		return base.onInvestigationAction(_board, _payload, _investigated_address);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
