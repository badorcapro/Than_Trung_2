using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Partner : RoleData
{
	private int target_address = -1;

	public override Roles role => Roles.PARTNER;

	public override string english_name => "Partner";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " and corresponding identity of an " + Keywords.UNINVESTIGATED.toString() + " " + Keywords.ROLE.toString() + ".\nStarts " + TextHelper.investigated + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I start " + TextHelper.investigated + " even when I am " + TextHelper.lying + " or " + TextHelper.tainted + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I pick a random " + Keywords.UNINVESTIGATED.toString() + " " + Keywords.ADDRESS.toString() + " and " + Keywords.ANNOUNCE.toString() + " they are a random " + Keywords.NOT_IN_PLAY.toString() + " " + Keywords.ROLE.toString() + "."));
			list.Add((DescriptionType.SPECIAL, "I will say \"Hi partner\" if I trigger and all " + TextHelper.roles + " are " + TextHelper.investigated + " regardless of if I am " + TextHelper.lyingOrTainted + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public Partner(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Partner(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		target_address = int.Parse(_save.unique_data);
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return _occupent.maybe_a.value.getAddress() == target_address;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		List<RoleData> list = _snap.board.getRolesInPlay().Values.Where((RoleData _e) => !_e.getIsInvestigated()).ToList();
		if (list.Count == 0)
		{
			return "Hi Partner!";
		}
		if (base.case_ref.hasMarkerQuirk(CaseQuirks.GOOD_INTUITION) && random.Next(0, 3) == 0 && list.Where((RoleData _e) => _e.getVisualClassification() == RoleClassifications.UNDERLING).Count() > 0)
		{
			list.shuffle(random);
			target_address = list.Where((RoleData _e) => _e.getVisualClassification() == RoleClassifications.UNDERLING).First().getAddress();
		}
		else
		{
			target_address = list.getRandomElementFromList(random).getAddress();
		}
		string target_name = (base.has_bad_info ? _snap.board.getRolesNotInPlay(_snap.true_suspect_list).getRandomElementFromList(random).name : _snap.board.getRolesInPlay()[target_address].name);
		return getInfo(target_address, target_name);
	}

	private string getInfo(int _target_address, string _target_name)
	{
		return checkTranslationWithReplace(() => getInfoEnglish(_target_address.ToString(), _target_name), ((object)_target_address).ToString, () => _target_name);
	}

	private string getInfoEnglish(string _data_1, string _data_2)
	{
		return "#" + _data_1 + " is the " + _data_2;
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		setInvestigatedOuter();
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return target_address.ToString();
	}
}
