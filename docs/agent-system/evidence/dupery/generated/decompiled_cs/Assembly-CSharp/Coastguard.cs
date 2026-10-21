using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Coastguard : DocksRoleData
{
	public override Roles role => Roles.COASTGUARD;

	public override string english_name => "Coastguard";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " the identity of the closest " + Keywords.UNARRESTED.toString() + " " + TextHelper.evilRole + " to the " + Keywords.BOAT.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "If all " + TextHelper.evilRoles + " are " + TextHelper.arrested + ", I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\""));
			list.Add((DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.ANNOUNCE.toString() + " a random " + Keywords.SUSPECTED.toString() + " " + RoleClassifications.UNDERLING.toString() + " or " + RoleClassifications.TRAITOR.toString() + " that is incorrect."));
			return list;
		}
	}

	public override bool hasInfo => true;

	private string loc_no_info_key => $"{role} [info_no]";

	public Coastguard(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Coastguard(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type != DescriptionType.SPECIAL)
		{
			return _description;
		}
		return _description.Replace(RoleData.loc_marker_1, checkTranslation(loc_no_info_key, englishInfoNoEvil));
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

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		List<RoleData> evil_role = _snap.board.getClosestAliveAndUnarrestedEvilFromCurrentPos(_snap.docks_payload.boat.position, _include_self: true);
		if (evil_role.Count == 0)
		{
			if (base.has_bad_info)
			{
				return info(_snap.true_suspect_list.Where((RoleData _r) => _r.getVisualClassification().equalToAny(RoleClassifications.TRAITOR, RoleClassifications.UNDERLING)).ToList().getRandomElementFromList(random));
			}
			return checkTranslation(loc_no_info_key, englishInfoNoEvil);
		}
		if (base.has_bad_info)
		{
			List<RoleData> list = _snap.true_suspect_list.Where((RoleData _r) => _r.getVisualClassification().equalToAny(RoleClassifications.TRAITOR, RoleClassifications.UNDERLING) && !evil_role.Any((RoleData _er) => _er.role == _r.role)).ToList();
			if (list.Count == 0)
			{
				return checkTranslation(loc_no_info_key, englishInfoNoEvil);
			}
			return info(list.getRandomElementFromList(random));
		}
		return info(evil_role.getRandomElementFromList(random));
	}

	private string info(RoleData _data)
	{
		return checkTranslationWithData(englishInfo, _data.name);
	}

	private string englishInfo(string _data)
	{
		return "Watch out for the " + _data + ".";
	}

	private string englishInfoNoEvil()
	{
		return "The coast is clear.";
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
