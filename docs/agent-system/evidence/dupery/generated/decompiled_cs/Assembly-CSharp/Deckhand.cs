using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Deckhand : DocksRoleData
{
	public override Roles role => Roles.DECKHAND;

	public override string english_name => "Deckhand";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " how many " + TextHelper.aliveAndNotArrested + " " + TextHelper.innocentRoles + " are closer to the " + Keywords.BOAT.toString() + " than the nearest " + TextHelper.aliveAndNotArrested + " " + TextHelper.evilRole + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)>
	{
		(DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves),
		(DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.ANNOUNCE.toString() + " a random number that is incorrect.")
	};

	public override bool hasInfo => true;

	private string loc_no_info_key => $"{role} [info_no]";

	public Deckhand(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Deckhand(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		Dictionary<int, RoleData> address_occupents = _snap.address_occupents;
		Vector2Int boat_pos = _snap.docks_payload.boat.position;
		List<KeyValuePair<int, RoleData>> list = address_occupents.Where((KeyValuePair<int, RoleData> _r) => _r.Value.getVisualAlignment() == Alignments.EVIL && !_r.Value.getIsArrested() && !_r.Value.getIsDead()).ToList();
		if (list.Count == 0)
		{
			if (base.has_bad_info)
			{
				return checkTranslationWithPlural(englishInfo, random.Next(0, _snap.classification_ratio[RoleClassifications.INNOCENT]));
			}
			return checkTranslation(loc_no_info_key, englishNoInfo);
		}
		int closest_evil = list.Aggregate(-1, (int _a, KeyValuePair<int, RoleData> _r) => (_a != -1) ? Mathf.Min(_a, _r.Value.getBoardPosition().cardinalDistance(boat_pos)) : _r.Value.getBoardPosition().cardinalDistance(boat_pos));
		int num = address_occupents.Count((KeyValuePair<int, RoleData> _r) => _r.Value.getVisualClassification() == RoleClassifications.INNOCENT && _r.Value.getBoardPosition().cardinalDistance(boat_pos) < closest_evil && !_r.Value.getIsArrested() && !_r.Value.getIsDead());
		if (base.has_bad_info)
		{
			int num2 = random.Next(0, _snap.classification_ratio[RoleClassifications.INNOCENT] + 1);
			if (num2 == num)
			{
				num2 = num2 % _snap.classification_ratio[RoleClassifications.INNOCENT] + 1;
			}
			return checkTranslationWithPlural(englishInfo, num2);
		}
		return checkTranslationWithPlural(englishInfo, num);
	}

	private string englishInfo(string _data)
	{
		return "I can see " + _data + " helper{#/s}.";
	}

	private string englishNoInfo()
	{
		return "There is no more danger.";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (base.dead)
		{
			return _board;
		}
		resetInfo();
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKillAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		if (base.dead)
		{
			return _board;
		}
		resetInfo();
		return base.onKillAction(_board, _payload, _murdered_address, _killer);
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

	public override string getUniqueSaveData()
	{
		return "";
	}
}
