using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class TreasureHunter : DocksRoleData
{
	private int role_hidden = -1;

	private int distance_to_role = -1;

	public override Roles role => Roles.TREASURE_HUNTER;

	public override string english_name => "Treasure Hunter";

	public override string english_description => "I " + Keywords.HIDE.toString() + " a " + RoleClassifications.MEDDLER.toString() + " or " + TextHelper.underlingRole + ". I " + Keywords.ANNOUNCE.toString() + " how many " + Keywords.STEPS.toString() + " the " + Keywords.BOAT.toString() + " is from the " + Keywords.ROLE.toString() + " I " + TextHelper.hid + ". " + TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.HIDE.toString() + " an " + TextHelper.innocentRole + " instead.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I cannot " + Keywords.HIDE.toString() + " myself."));
			list.Add((DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves));
			list.Add((DescriptionType.LYING_OR_TAINTED, "I truthfully " + Keywords.ANNOUNCE.toString() + " how many " + Keywords.STEPS.toString() + " the " + Keywords.BOAT.toString() + " is from the " + Keywords.ROLE.toString() + " I " + TextHelper.hid + " even when I am " + TextHelper.lyingOrTainted + "."));
			return list;
		}
	}

	public override string credits => "Exiliado89";

	public override int execution_order => CaseHelper.LAST_MEDDLER;

	public override bool hasInfo => true;

	public override bool has_truth_hover_focus => role_hidden > 0;

	private string loc_no_info_key => $"{role} [info_no]";

	public TreasureHunter(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public TreasureHunter(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			role_hidden = int.Parse(array[0]);
			distance_to_role = int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}!\nSave: {_save.unique_data}\nError: {arg}");
			role_hidden = -1;
			distance_to_role = -1;
		}
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		if (role_hidden == -1)
		{
			return checkTranslation(loc_no_info_key, englishNoInfo);
		}
		return checkTranslationWithPlural(_replace: distance_to_role = _snap.board.getRolesInPlay()[role_hidden].getBoardPosition().cardinalDistance(_snap.docks_payload.boat.position), _english: englishInfo);
	}

	private string englishInfo(string _data)
	{
		return "I've hidden a treasure " + _data + " step{#/s} away.";
	}

	private string englishNoInfo()
	{
		return "I found no treasure.";
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HIDES);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.dead || base.arrested)
		{
			return _board;
		}
		List<RoleData> list = (base.has_bad_info ? _board.getRolesInPlayOfClass(default(RoleClassifications)) : _board.getRolesInPlayOfClass(RoleClassifications.MEDDLER, RoleClassifications.UNDERLING)).Where((RoleData _r) => !_r.getIsHidden() && _r.getAddress() != base.address).ToList();
		if (list.Count == 0)
		{
			return _board;
		}
		RoleData randomElementFromList = list.getRandomElementFromList(random);
		role_hidden = randomElementFromList.getAddress();
		randomElementFromList.setHidden(_new: true);
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.dead)
		{
			return _board;
		}
		resetInfo();
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getTruthString()
	{
		return ((role_hidden > 0) ? (TextHelper.hidOneLocalised(role_hidden) + "\n") : "") + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == role_hidden;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return $"{role_hidden},{distance_to_role}";
	}
}
