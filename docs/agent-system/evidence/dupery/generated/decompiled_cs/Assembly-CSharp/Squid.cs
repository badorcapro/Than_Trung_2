using System;
using System.Collections.Generic;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Squid : DocksRoleData
{
	private int target = -1;

	private bool forced_target;

	public override Roles role => Roles.SQUID;

	public override string english_name => "Squid";

	public override string english_description => "I " + Keywords.HIDE.toString() + " a " + TextHelper.surroundingNeighbour + ". " + TextHelper.iLieAndPretendSuspected + ".";

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => target > 0;

	public Squid(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Squid(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			target = int.Parse(_save.unique_data);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			target = -1;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HIDES, new PositionRoleGC(GCPosition.SURROUNDING, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.tainted || base.dead)
		{
			return _board;
		}
		if (forced_target)
		{
			_board.getRolesInPlay()[target].setHidden(_new: true);
			return _board;
		}
		List<RoleData> surroundingRolesFromGridPos = _board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size);
		if (surroundingRolesFromGridPos.Count == 0)
		{
			Debug.LogError($"{role} found no surrounding neighbours to hide!");
			return _board;
		}
		RoleData randomElementFromList = surroundingRolesFromGridPos.getRandomElementFromList(random);
		target = randomElementFromList.getAddress();
		randomElementFromList.setHidden(_new: true);
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public void setForcedTarget(int _address)
	{
		forced_target = true;
		target = _address;
	}

	public override string getTruthString()
	{
		return ((target == -1) ? "" : (TextHelper.hidOneLocalised(target) + "\n")) + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == target;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return target.ToString();
	}
}
