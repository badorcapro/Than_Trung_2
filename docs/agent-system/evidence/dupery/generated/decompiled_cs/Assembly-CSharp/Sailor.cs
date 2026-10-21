using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Sailor : DocksRoleData
{
	public override Roles role => Roles.SAILOR;

	public override string english_name => "Sailor";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " how many " + TextHelper.lyingOrTainted + " " + TextHelper.goodRoles + " are " + Keywords.CARDINALLY_ADJACENT.toString() + " to the " + Keywords.BOAT.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)>
	{
		(DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves),
		(DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a random number that is incorrect.")
	};

	public override bool hasInfo => true;

	public Sailor(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Sailor(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new List<AdvancedGenerationConstraint>
		{
			new InPlayRequireRoleGC(RoleGenerationMarkers.TAINTS),
			new LeadRequireGC(new List<RoleClassifications>
			{
				RoleClassifications.MEDDLER,
				RoleClassifications.UNDERLING
			}, RoleGenerationMarkers.TAINTS, 2)
		});
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		List<RoleData> adjacentRolesFromGridPos = _snap.board.getAdjacentRolesFromGridPos(_snap.docks_payload.boat.position, base.case_ref.board_size);
		int num = adjacentRolesFromGridPos.Count((RoleData _r) => _r.has_bad_info && _r.getVisualAlignment() == Alignments.GOOD);
		if (base.has_bad_info)
		{
			if (adjacentRolesFromGridPos.Count == 0)
			{
				return checkTranslationWithPlural(englishInfo, 1);
			}
			int num2 = random.Next(0, adjacentRolesFromGridPos.Count + 1);
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
		return "I see " + _data + " fool{#/s}.";
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
