using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class PirateCaptain : DocksRoleData
{
	private List<int> killed_targets = new List<int>();

	public override Roles role => Roles.PIRATE_CAPTAIN;

	public override string english_name => "Pirate Captain";

	public override string english_description => "Whenever the " + Keywords.BOAT.toString() + " moves towards me, I " + Keywords.KILL.toString() + " a random " + Keywords.ROLE.toString() + " if possible. " + TextHelper.iLieAndPretendNotInPlay + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I have a higher chance of " + TextHelper.killing + " " + TextHelper.goodRoles + " than " + Alignments.EVIL.toString() + " ones."));
			list.Add((DescriptionType.SPECIAL, "The " + Keywords.BOAT.toString() + " is considered to have moved towards me if the number of " + Keywords.STEPS.toString() + " it would need to get to me decreased with the " + "boats".asKeyword(Keywords.BOAT) + " movement."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => killed_targets.Count > 0;

	public PirateCaptain(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public PirateCaptain(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			killed_targets = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			killed_targets = new List<int>();
		}
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		return "";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.tainted || base.dead || base.arrested)
		{
			return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
		}
		if (_old_pos.cardinalDistance(base.board_position) > _new_pos.cardinalDistance(base.board_position))
		{
			List<RoleData> list = _board.getRolesInPlay().Values.Where((RoleData _r) => !_r.getIsDead() && !_r.getIsArrested()).ToList();
			if (list.Count == 0)
			{
				return _board;
			}
			int item = list.Select((RoleData _e) => (_e: _e, (_e.role.getClassificationFromRoleType() == RoleClassifications.INNOCENT || _e.role.getClassificationFromRoleType() == RoleClassifications.MEDDLER) ? 20 : ((_e.role.getClassificationFromRoleType() != RoleClassifications.UNDERLING) ? 1 : 5))).ToList().weightedChoose(random)
				.value.getAddress();
			_board = base.case_ref.killAddress(item, ((RoleData)this).maybe()).board;
			killed_targets.Add(item);
		}
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getUniqueSaveData()
	{
		return killed_targets.toStringCommaSeperated();
	}

	public override string getTruthString()
	{
		return ((killed_targets.Count == 0) ? "" : (TextHelper.killedManyLocalised(killed_targets) + "\n")) + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return killed_targets.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}
}
