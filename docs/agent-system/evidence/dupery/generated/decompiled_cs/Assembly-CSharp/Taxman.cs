using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Taxman : CasinoRoleData
{
	private static int lose_on_target = 5;

	public override Roles role => Roles.TAXMAN;

	public override string english_name => "Taxman";

	public override string english_description => $"Whenever you target me with an {Keywords.ABILITY.toString()}, lose {lose_on_target} {TextHelper.chips_with_link}.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", you do not lose any additional " + TextHelper.chips_with_link + " when targetting me with an " + Keywords.ABILITY.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public Taxman(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Taxman(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new InPlayRequireRoleGC(RoleGenerationMarkers.HAS_ABILITY, 1, DisguiseConstraintType.NEVER_IGNORE));
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (base.arrested || base.dead || base.has_bad_info)
		{
			return _board;
		}
		if (_target_addresses.Contains(base.address))
		{
			base.casino_case.spendChips(lose_on_target);
		}
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
