using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Localisation;
using Save;
using UnityEngine;

public class Nymph : DocksRoleData
{
	public override Roles role => Roles.NYMPH;

	public override string english_name => "Nymph";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.CLASSIFICATION.toString() + " of the " + Keywords.ROLE.toString() + " in the mirrored position of the " + Keywords.BOAT.toString() + " on the " + Keywords.BOARD.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "If there is no " + Keywords.ROLE.toString() + " on the mirrored position of the " + Keywords.BOAT.toString() + " on the " + Keywords.BOARD.toString() + ", I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\" even when I am " + TextHelper.lyingOrTainted + "."));
			list.Add((DescriptionType.SPECIAL, TextHelper.iUpdateWhenBoatMoves));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I will " + Keywords.ANNOUNCE.toString() + " a random " + Keywords.CLASSIFICATION.toString() + " that is incorrect when a " + Keywords.ROLE.toString() + " is in a mirrored position of the " + Keywords.BOAT.toString() + " on the " + Keywords.BOARD.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	private string loc_nothing_info_key => $"{role} [info_no]";

	public Nymph(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Nymph(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type != DescriptionType.SPECIAL)
		{
			return _description;
		}
		return _description.Replace(RoleData.loc_marker_1, checkTranslation(loc_nothing_info_key, englishInfoNoOne));
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		Vector2Int mirroredPosition = _snap.docks_payload.boat.position.getMirroredPosition(base.case_ref.board_size);
		if (!_snap.board[mirroredPosition].is_some || !_snap.board[mirroredPosition].value.is_a)
		{
			return checkTranslation(loc_nothing_info_key, englishInfoNoOne);
		}
		RoleClassifications visualClassification = _snap.board[mirroredPosition].value.maybe_a.value.getVisualClassification();
		if (base.has_bad_info)
		{
			RoleClassifications randomElementFromList = new List<RoleClassifications>().addAll().remove(visualClassification).getRandomElementFromList(random);
			return LocalisationHelper.checkOption(checkTranslationWithData(englishInfo, randomElementFromList.toStringPlain()), randomElementFromList.getPrefixOption());
		}
		return LocalisationHelper.checkOption(checkTranslationWithData(englishInfo, visualClassification.toStringPlain()), visualClassification.getPrefixOption());
	}

	private string englishInfo(string _data)
	{
		return "A{#/n} " + _data + " disturbs the sea.";
	}

	private string englishInfoNoOne()
	{
		return "No one disturbs the sea.";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _position.getMirroredPosition(base.case_ref.board_size) == base.docks_case.boat.position;
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
		return base.onBoatMoveAction(_board, _payload, _old_pos, _new_pos);
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
