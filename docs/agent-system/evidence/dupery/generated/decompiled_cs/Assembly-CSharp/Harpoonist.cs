using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Harpoonist : DocksRoleData
{
	private int target = -1;

	public override Roles role => Roles.HARPOONIST;

	public override string english_name => "Harpoonist";

	public override string english_description => "I pick an " + RoleClassifications.INNOCENT.toString() + " " + TextHelper.adjacentNeighbour + ". I " + Keywords.TAINT.toString() + " them while I am not on the " + Keywords.BOAT.toString() + ", " + TextHelper.aliveAndNotArrested + ". " + TextHelper.iLieAndPretendSuspected + ".";

	public override bool hasInfo => false;

	public Harpoonist(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Harpoonist(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
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

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.TAINTS, new PositionRoleGC(RoleClassifications.INNOCENT, GCPosition.ADJACENT, DisguiseConstraintType.ALWAYS_IGNORE));
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		List<RoleData> list = (from _r in _board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size)
			where _r.getVisualClassification() == RoleClassifications.INNOCENT
			select _r).ToList();
		if (list.Count == 0)
		{
			Debug.LogError("No adjacent innocent roles! This should not be possible!");
			return _board;
		}
		RoleData randomElementFromList = list.getRandomElementFromList(random);
		target = randomElementFromList.getAddress();
		if (base.tainted || base.dead || base.arrested)
		{
			return _board;
		}
		randomElementFromList.setTempTaint(this, _true: true);
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.tainted || base.dead || base.arrested || (_old_pos != base.board_position && _new_pos != base.board_position))
		{
			return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
		}
		setTargetTaint(_board, base.board_position != _new_pos);
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	private void setTargetTaint(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, bool _true)
	{
		RoleData roleData = _board.getRolesInPlay()[target];
		bool isTainted = roleData.getIsTainted();
		roleData.setTempTaint(this, _true);
		if (isTainted != roleData.getIsTainted())
		{
			roleData.resetInfo();
		}
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (_arrested_address == base.address)
		{
			setTargetTaint(_board, _true: false);
		}
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKillAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		if (_murdered_address == base.address)
		{
			setTargetTaint(_board, _true: false);
		}
		return base.onKillAction(_board, _payload, _murdered_address, _killer);
	}

	public override string getUniqueSaveData()
	{
		return target.ToString();
	}

	public override string getTruthString()
	{
		return ((target == -1) ? "" : checkTranslationWithData(base.loc_default_truth_key, getTruthEnglish, target)) + "\n" + base.getTruthString();
	}

	private string getTruthEnglish(string _data)
	{
		return "I toyed with " + _data + ".";
	}
}
