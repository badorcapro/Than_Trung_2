using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Gunner : DocksRoleData
{
	private bool forced_target;

	private int target = -1;

	private bool info_triggered;

	public override Roles role => Roles.GUNNER;

	public override string english_name => "Gunner";

	public override string english_description => "I " + Keywords.TAINT.toString() + " an " + TextHelper.innocentRole + " that is not " + Keywords.CARDINALLY_ADJACENT.toString() + " to me. When the " + Keywords.BOAT.toString() + " is moved onto me, I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of the " + Keywords.ROLE.toString() + " I " + TextHelper.tainted + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.TAINT.toString() + " no one and I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of a random " + TextHelper.truthfulRole + "."));
			return list;
		}
	}

	public override bool hasInfo => info_triggered;

	public override bool has_truth_hover_focus => target != -1;

	private string loc_no_taint_key => $"{role} [info_no]";

	public Gunner(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Gunner(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			target = int.Parse(array[0]);
			info_triggered = array[1] == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			target = -1;
			info_triggered = base.info_string.is_some;
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.TAINTS, new PositionRoleGC(RoleClassifications.INNOCENT, GCPosition.NOT_ADJACENT, DisguiseConstraintType.IGNORE_WHEN_LYING));
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		if (base.has_bad_info)
		{
			List<KeyValuePair<int, RoleData>> list = _snap.address_occupents.Where((KeyValuePair<int, RoleData> _r) => !_r.Value.has_bad_info && _r.Key != target).ToList();
			if (list.Count == 0)
			{
				return checkTranslation(loc_no_taint_key, englishNoTaint);
			}
			return checkTranslationWithData(englishInfo, list.getRandomElementFromList(random).Key);
		}
		if (target == -1)
		{
			Debug.LogError("Feel like this should not be possible?");
			return checkTranslation(loc_no_taint_key, englishNoTaint);
		}
		return checkTranslationWithData(englishInfo, target);
	}

	private string englishInfo(string _data)
	{
		return "I tainted #" + _data;
	}

	private string englishNoTaint()
	{
		return "I tainted no one.";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.has_bad_info || base.dead)
		{
			return _board;
		}
		if (forced_target)
		{
			_board.getRolesInPlay()[target].setTainted(_new: true);
			return _board;
		}
		List<KeyValuePair<int, RoleData>> list = (from _r in _board.getRolesInPlay()
			where _r.Value.getVisualClassification() == RoleClassifications.INNOCENT && !_r.Value.getBoardPosition().isAdjacent(base.board_position)
			select _r).ToList();
		if (list.Count == 0)
		{
			Debug.LogError($"{role} found no targets to taint!!!");
			return _board;
		}
		RoleData value = list.getRandomElementFromList(random).Value;
		value.setTainted(_new: true);
		target = value.getAddress();
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.dead || _new_pos != base.board_position)
		{
			return _board;
		}
		info_triggered = true;
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public void setForcedTarget(int _address)
	{
		forced_target = true;
		target = _address;
	}

	public override string getTruthString()
	{
		return ((target == -1) ? "" : (TextHelper.taintedOneLocalised(target) + "\n")) + base.getTruthString();
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
		return string.Format("{0},{1}", target, info_triggered ? "t" : "f");
	}
}
