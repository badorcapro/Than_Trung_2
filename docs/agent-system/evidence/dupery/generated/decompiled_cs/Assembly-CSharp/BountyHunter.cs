using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class BountyHunter : RoleData
{
	private int target_a = -1;

	private int target_b = -1;

	private int actual_target = -1;

	private bool forced_targets;

	public override Roles role => Roles.BOUNTY_HUNTER;

	public override string english_name => "Bounty Hunter";

	public override string english_description => "I pick and " + Keywords.TAINT.toString() + " an " + TextHelper.innocentRole + ".\n" + TextHelper.whenInvestigated + ", I " + Keywords.ANNOUNCE.toString() + " 2 " + TextHelper.addresses + ", one of which belongs to my " + Keywords.TARGET.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "My " + Keywords.TARGET.toString() + " can already be " + TextHelper.tainted + " when I pick them."));
			list.Add((DescriptionType.SPECIAL, "Apart from my " + TextHelper.innocent + " " + Keywords.TARGET.toString() + ", the other " + TextHelper.addresses + " can be anyone else, and can also be " + TextHelper.tainted + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I will not " + Keywords.TAINT.toString() + " any " + Keywords.ROLE.toString() + " and I will " + Keywords.ANNOUNCE.toString() + " the " + TextHelper.addresses + " of 2 non-" + TextHelper.innocentRoles + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_truth_hover_focus => actual_target != -1;

	public override bool has_hover_focus => true;

	private string loc_info_late_key => $"{role} [late_info]";

	public BountyHunter(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public BountyHunter(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		string[] array = _save.unique_data.Split(",");
		target_a = int.Parse(array[0]);
		target_b = int.Parse(array[1]);
		actual_target = int.Parse(array[2]);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.TAINTS);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (forced_targets || actual_target != -1)
		{
			return checkTranslationWithReplace(() => getInfoEnglish(target_a, target_b), target_a, target_b);
		}
		if (!base.has_bad_info)
		{
			return checkTranslation(loc_info_late_key, getInfoLateEnglish);
		}
		List<RoleData> list = _snap.address_occupents.Values.Where((RoleData _r) => _r.getVisualClassification() != RoleClassifications.INNOCENT).ToList();
		if (list.Count > 2)
		{
			list.RemoveAll((RoleData _r) => _r.getAddress() == base.address);
		}
		list.shuffle(random);
		target_a = list[0].getAddress();
		target_b = list[1].getAddress();
		if (target_a > target_b)
		{
			int num = target_a;
			target_a = target_b;
			target_b = num;
		}
		return checkTranslationWithReplace(() => getInfoEnglish(target_a, target_b), target_a, target_b);
	}

	private string getInfoEnglish(int _data_1, int _data_2)
	{
		return getInfoEnglish(_data_1.ToString(), _data_2.ToString());
	}

	private string getInfoEnglish(string _data_1, string _data_2)
	{
		return "My target is #" + _data_1 + " or #" + _data_2 + ".";
	}

	private string getInfoLateEnglish()
	{
		return "I arrived late. I have no targets.";
	}

	public override string getTruthString()
	{
		return ((actual_target == -1) ? "" : (TextHelper.taintedOneLocalised(actual_target) + "\n")) + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == actual_target;
		}
		return false;
	}

	public override List<RevealLineSettings> getRevealLines(CaseSnapshot _snap)
	{
		if (actual_target != -1)
		{
			return getRevealLineToTarget(actual_target, RevealLineColour.PURPLE, _snap);
		}
		return new List<RevealLineSettings>();
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return _occupent.maybe_a.value.getAddress().equalToAny(target_a, target_b);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.has_bad_info)
		{
			actual_target = -1;
			return _board;
		}
		if (forced_targets)
		{
			_board.getRolesInPlay()[actual_target].setTainted(_new: true);
			return _board;
		}
		List<int> list = (from _e in _board.getRolesInPlay().Values
			where _e.getVisualClassification() == RoleClassifications.INNOCENT
			select _e into _h
			select _h.getAddress()).ToList();
		list.shuffle(random);
		int good_address = list.First();
		List<int> list2 = (from _e in _board.getRolesInPlay().Values
			select _e.getAddress() into _e
			where _e != good_address && _e != getAddress()
			select _e).ToList();
		list2.shuffle(random);
		int[] array = new int[2]
		{
			good_address,
			list2[1]
		}.OrderBy((int _e) => _e).ToArray();
		target_a = array[0];
		target_b = array[1];
		actual_target = good_address;
		_board.getRolesInPlay()[actual_target].setTainted(_new: true);
		return _board;
	}

	public override string getUniqueSaveData()
	{
		return $"{target_a},{target_b},{actual_target}";
	}

	public void setForcedTarget(int _real_target, List<int> _announces)
	{
		actual_target = _real_target;
		target_a = _announces[0];
		target_b = _announces[1];
		forced_targets = true;
	}
}
