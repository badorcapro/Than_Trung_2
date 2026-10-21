using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Mathematician : RoleData
{
	private List<int> parts = new List<int>();

	public override Roles role => Roles.MATHEMATICIAN;

	public override string english_name => "Mathematician";

	public override string english_description => TextHelper.whenInvestigated + ", I " + Keywords.ANNOUNCE.toString() + " the sum of all " + TextHelper.evilRole + " " + "addresses".asKeyword(Keywords.ADDRESS) + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " a sum that is either higher or lower than the true sum.") };

	public override bool hasInfo => true;

	public override bool has_end_info_hover_focus => parts.Count > 0;

	public Mathematician(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Mathematician(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			parts = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading {role} failed!\nData:{_save.unique_data}\nError:{arg}");
			parts = new List<int>();
		}
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		List<int> source = (from _e in _snap.board.getRolesInPlay().Values
			where _e.getVisualAlignment() == Alignments.EVIL
			select _e.getAddress()).ToList();
		int num = source.Aggregate(0, (int _a, int _b) => _a += _b);
		if (base.has_bad_info)
		{
			int num2 = Mathf.Max(Mathf.Min(10, Mathf.RoundToInt((float)num * 0.35f)), 4);
			int num3 = random.Next(Mathf.Max(num - num2, 1), num + num2);
			if (num3 >= num)
			{
				num3++;
			}
			return infoString(num3);
		}
		parts = source;
		return infoString(num);
	}

	private string infoString(int _sum)
	{
		return checkTranslationWithReplace(() => getInfoEnglish(_sum.ToString()), ((object)_sum).ToString);
	}

	private string getInfoEnglish(string _data)
	{
		return "I have calculated the number " + _data + ".";
	}

	public RoleData createAndForceSetInfo(int _sum)
	{
		base.info_string = infoString(_sum).maybe();
		return this;
	}

	public override bool checkEndInfoHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return parts.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.INNOCENT;
	}

	public override string getUniqueSaveData()
	{
		return parts.toStringCommaSeperated();
	}
}
