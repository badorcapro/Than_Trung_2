using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class LighthouseKeeper : DocksRoleData
{
	public override Roles role => Roles.LIGHTHOUSE_KEEPER;

	public override string english_name => "Lightkeeper";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " how many " + TextHelper.evilRoles + " are closer to the " + LocationTypes.LIGHTHOUSE.toString() + " than the " + Keywords.BOAT.toString() + " is. I add a " + LocationTypes.LIGHTHOUSE.toString() + " on the " + Keywords.BOARD.toString() + " when I am " + Keywords.SUSPECTED.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)>
	{
		(DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves),
		(DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a random number that is incorrect.")
	};

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public LighthouseKeeper(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public LighthouseKeeper(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new SuspectLocationGC(LocationTypes.LIGHTHOUSE));
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_b)
		{
			return false;
		}
		if (!(_snap is DocksCaseSnapshot docksCaseSnapshot))
		{
			Debug.LogError("Lighthouse keeper was not given a docks case snapshot?! This isnt allowed!");
			return false;
		}
		Vector2Int position = docksCaseSnapshot.docks_payload.boat.position;
		Vector2Int boardPosition = _snap.board.getLocationsInPlay()[LocationTypes.LIGHTHOUSE].getBoardPosition();
		return boardPosition.cardinalDistance(position) > _position.cardinalDistance(boardPosition);
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		Vector2Int position = _snap.docks_payload.boat.position;
		Vector2Int l_pos = _snap.board.getLocationsInPlay()[LocationTypes.LIGHTHOUSE].getBoardPosition();
		int dist_boat = l_pos.cardinalDistance(position);
		List<RoleData> list = _snap.address_occupents.Values.Where((RoleData _r) => _r.getBoardPosition().cardinalDistance(l_pos) < dist_boat).ToList();
		int num = list.Count((RoleData _r) => _r.getVisualAlignment() == Alignments.EVIL);
		if (base.has_bad_info)
		{
			if (list.Count == 0)
			{
				return checkTranslationWithPlural(englishInfo, 1);
			}
			int num2 = random.Next(0, Mathf.Min(list.Count, _snap.address_occupents.Values.Count((RoleData _r) => _r.getVisualAlignment() == Alignments.EVIL) + 1));
			if (num2 == num)
			{
				num2--;
				if (num2 == -1)
				{
					num2 = 1;
				}
			}
			return checkTranslationWithPlural(englishInfo, num2);
		}
		return checkTranslationWithPlural(englishInfo, num);
	}

	private string englishInfo(string _data)
	{
		return "The waters ahead have " + _data + " evil role{#/s}.";
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

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}
}
