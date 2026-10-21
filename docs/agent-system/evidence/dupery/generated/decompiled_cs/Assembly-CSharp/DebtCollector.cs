using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class DebtCollector : CasinoRoleData
{
	private const int ability_price_increase = 4;

	private int additional_cost;

	public override Roles role => Roles.DEBT_COLLECTOR;

	public override string english_name => "Debt Collector";

	public override string english_description => $"While I am {Keywords.ALIVE.toString()} and not {TextHelper.arrested}, the {TextHelper.abilities} of my {TextHelper.surroundingNeighbours} cost an additional {4} {TextHelper.chips_with_link} to use. {TextHelper.iLieAndPretendSuspected}.";

	public override bool hasInfo => false;

	public DebtCollector(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public DebtCollector(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			additional_cost = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Something went wrong parsing save data! ({role} | '{_save.unique_data}')\nError: {arg}");
			additional_cost = 0;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new PositionRoleGC(RoleGenerationMarkers.HAS_ABILITY, GCPosition.SURROUNDING, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (base.tainted || base.arrested || base.dead)
		{
			return _board;
		}
		if (_ability_user_address == base.address)
		{
			return _board;
		}
		if (!_board.getRolesInPlay()[_ability_user_address].getBoardPosition().isSurroundingOrOn(base.board_position))
		{
			return _board;
		}
		base.casino_case.spendChips(4);
		additional_cost += 4;
		return _board;
	}

	public override string getTruthString()
	{
		return ((additional_cost > 0) ? (checkTranslationWithData(base.loc_default_truth_key, englishTruth, additional_cost) + "\n") : "") + base.getTruthString();
	}

	private string englishTruth(string _data)
	{
		return "I made you lose " + _data + " chips!";
	}

	public override string getUniqueSaveData()
	{
		return additional_cost.ToString();
	}
}
