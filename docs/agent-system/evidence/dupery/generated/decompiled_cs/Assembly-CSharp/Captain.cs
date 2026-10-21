using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Captain : DocksRoleData
{
	private const int am_fuel = 2;

	private bool fuel_regained;

	public override Roles role => Roles.CAPTAIN;

	public override string english_name => "Captain";

	public override string english_description => $"I {Keywords.ANNOUNCE.toString()} if the {Keywords.BOAT.toString()} is {Keywords.SURROUNDING.toString()} or on a {TextHelper.traitorRole}. The first time the {Keywords.BOAT.toString()} is moved onto me, regain {2} {Keywords.FUEL.toString()}.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "When the " + Keywords.BOAT.toString() + " is " + Keywords.SURROUNDING.toString() + " a " + TextHelper.traitorRole + ", I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\". Otherwise I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_2 + "\""));
			list.Add((DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounceOppositeOfTrue));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	private string loc_no_info_key => $"{role} [info_no]";

	public Captain(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Captain(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			fuel_regained = _save.unique_data == "t";
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			fuel_regained = false;
		}
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type != DescriptionType.SPECIAL)
		{
			return _description;
		}
		return _description.Replace(RoleData.loc_marker_1, checkTranslation(englishInfo)).Replace(RoleData.loc_marker_2, checkTranslation(loc_no_info_key, englishInfoNoTraitor));
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new ClassificationRatioGC(RoleClassifications.TRAITOR, 1, DisguiseConstraintType.NEVER_IGNORE));
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		bool flag = _snap.board.getRolesInPlay().Values.Any((RoleData _r) => _r.getVisualClassification() == RoleClassifications.TRAITOR && (_r.getBoardPosition() == _snap.docks_payload.boat.position || _r.getBoardPosition().isSurroundingOrOn(_snap.docks_payload.boat.position)));
		if (base.has_bad_info)
		{
			flag = !flag;
		}
		if (flag)
		{
			return checkTranslation(englishInfo);
		}
		return checkTranslation(loc_no_info_key, englishInfoNoTraitor);
	}

	private string englishInfo()
	{
		return "There is danger close by.";
	}

	private string englishInfoNoTraitor()
	{
		return "The waters are calm.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!(_snap.payload is DocksCaseActionPayload docksCaseActionPayload))
		{
			Debug.LogError($"Trying to check hover focus for role in the wrong region!!! {role}!");
			return false;
		}
		if (_occupent.is_a)
		{
			if (!_position.isSurroundingOrOn(docksCaseActionPayload.boat.position))
			{
				return _position == docksCaseActionPayload.boat.position;
			}
			return true;
		}
		return false;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onBoatMoveAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, DocksCaseActionPayload _payload, Vector2Int _old_pos, Vector2Int _new_pos)
	{
		if (base.dead)
		{
			return _board;
		}
		resetInfo();
		if (base.has_bad_info || fuel_regained || _new_pos != base.board_position)
		{
			return _board;
		}
		fuel_regained = true;
		base.docks_case.addFuel(2);
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getUniqueSaveData()
	{
		if (!fuel_regained)
		{
			return "";
		}
		return "t";
	}
}
