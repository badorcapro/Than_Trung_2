using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class PrivateInvestigator : ClockRoleData
{
	private int time_passed;

	private static int trigger_hour = 10;

	private int target_address = -1;

	public override Roles role => Roles.PRIVATE_INVESTIGATOR;

	public override string english_name => "Private Eye";

	public override string english_description => $"On the {trigger_hour}{trigger_hour.getOrdinalSuffix()} hour, I {Keywords.ANNOUNCE.toString()} the {Keywords.ADDRESS.toString()} of an {Keywords.UNINVESTIGATED.toString()} {RoleClassifications.UNDERLING.toString()} if possible.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "When there are no " + Keywords.UNINVESTIGATED.toString() + " " + TextHelper.underlingRoles + ", I will " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\""));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of a non-" + TextHelper.underlingRole + "."));
			return list;
		}
	}

	public override bool hasInfo => time_passed >= trigger_hour;

	public override bool has_hover_focus => target_address != -1;

	private string loc_no_info_key => $"{role} [no_info]";

	public PrivateInvestigator(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public PrivateInvestigator(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		string[] array = _save.unique_data.Split(',');
		target_address = int.Parse(array[0]);
		time_passed = int.Parse(array[1]);
	}

	protected override string fillExtraDescription(string _description, DescriptionType _type)
	{
		if (_type != DescriptionType.SPECIAL)
		{
			return _description;
		}
		return _description.Replace(RoleData.loc_marker_1, checkTranslation(loc_no_info_key, getBlankInfoEnglish));
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
		if (time_passed >= trigger_hour)
		{
			List<RoleData> list = _snap.board.getRolesInPlay().Values.Where((RoleData _r) => !_r.getIsInvestigated() && !_r.getIsArrested()).ToList();
			if (base.has_bad_info)
			{
				List<RoleData> list2 = list.Where((RoleData _r) => _r.getVisualClassification() != RoleClassifications.UNDERLING).ToList();
				if (list2.Count > 0)
				{
					list2.shuffle(random);
					target_address = list2[0].getAddress();
					return infoString(target_address);
				}
				target_address = (from _r in _snap.board.getRolesInPlay()
					where _r.Key != base.address && _r.Value.getIsInvestigated() && _r.Value.getVisualClassification() != RoleClassifications.UNDERLING
					select _r).ToList().getRandomElementFromList(random).Key;
				return infoString(target_address);
			}
			List<RoleData> list3 = list.Where((RoleData _r) => _r.getVisualClassification() == RoleClassifications.UNDERLING).ToList();
			if (list3.Count > 0)
			{
				list.shuffle(random);
				target_address = list3[0].getAddress();
				return infoString(target_address);
			}
			return checkTranslation(loc_no_info_key, getBlankInfoEnglish);
		}
		throw new InvalidOperationException("Info not cooked yet!");
	}

	private string infoString(int _address)
	{
		return checkTranslationWithReplace(() => getInfoEnglish(_address.ToString()), ((object)_address).ToString);
	}

	private string getInfoEnglish(string _data)
	{
		return "#" + _data + " is an underling.";
	}

	private string getBlankInfoEnglish()
	{
		return "I got nothing.";
	}

	protected override void setDisguiseData(Case _case_ref)
	{
		if (_case_ref != null && _case_ref is ClockCase clockCase)
		{
			time_passed = clockCase.getTrueHoursPassed();
		}
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _rep, int _new_time)
	{
		time_passed = _new_time;
		return base.onTimePassedAction(_board, _rep, _new_time);
	}

	public override string getUniqueSaveData()
	{
		return $"{target_address},{time_passed}";
	}
}
