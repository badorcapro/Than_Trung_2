using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Weatherman : RoleData
{
	private int[] addresses_said = new int[3] { -1, -1, -1 };

	public override Roles role => Roles.WEATHERMAN;

	public override string english_name => "Weatherman";

	public override string english_description => TextHelper.whenInvestigated + ", I " + Keywords.ANNOUNCE.toString() + " three " + TextHelper.addresses + ".\nOne " + Keywords.ADDRESS.toString() + " leads to an " + RoleClassifications.INNOCENT.toString() + ", one leads to a " + RoleClassifications.MEDDLER.toString() + ", and one leads to an " + RoleClassifications.UNDERLING.toString() + " or " + RoleClassifications.TRAITOR.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + " I " + Keywords.ANNOUNCE.toString() + " three " + TextHelper.addresses + ", all " + TextHelper.addresses + " are either " + TextHelper.innocent + " or " + TextHelper.meddlerRoles + "."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	private string loc_no_meddler_info_key => $"{role} [info_nm]";

	public Weatherman(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Weatherman(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			addresses_said = new int[3]
			{
				int.Parse(array[0]),
				int.Parse(array[1]),
				int.Parse(array[2])
			};
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}! '{_save.unique_data}' | Error: {arg}");
			addresses_said = new int[3] { -1, -1, -1 };
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(new List<AdvancedGenerationConstraint>
		{
			new VisualClassificationRatioGC(RoleClassifications.MEDDLER, 1, DisguiseConstraintType.NEVER_IGNORE),
			new InPlayRequireRoleGC(RoleClassifications.MEDDLER)
		});
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return addresses_said.Contains(_occupent.maybe_a.value.getAddress());
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		List<RoleData> list = _snap.board.getRolesInPlay().Values.Where((RoleData _e) => _e.getVisualClassification() == RoleClassifications.INNOCENT && _e.getAddress() != base.address).ToList();
		List<RoleData> list2 = _snap.board.getRolesInPlay().Values.Where((RoleData _e) => _e.getVisualClassification() == RoleClassifications.MEDDLER && _e.getAddress() != base.address).ToList();
		List<RoleData> list3 = _snap.board.getRolesInPlay().Values.Where((RoleData _e) => _e.getVisualClassification().equalToAny(RoleClassifications.UNDERLING, RoleClassifications.TRAITOR) && _e.getAddress() != base.address).ToList();
		List<int> list4 = new List<int>();
		if (base.has_bad_info)
		{
			list.AddRange(list2);
			list.shuffle(random);
			if (list.Count < 3)
			{
				if (getVisualClassification().equalToAny(RoleClassifications.INNOCENT, RoleClassifications.MEDDLER))
				{
					list.Add(base.is_true_self ? this : true_self.value);
				}
				for (int i = 0; i < list.Count && i < 3; i++)
				{
					list4.Add((i < list.Count) ? list[i].getAddress() : (-1));
				}
			}
			else
			{
				list4.Add(list[0].getAddress());
				list4.Add(list[1].getAddress());
				list4.Add(list[2].getAddress());
			}
		}
		else
		{
			list.shuffle(random);
			list2.shuffle(random);
			list3.shuffle(random);
			if (list2.Count == 0 && true_self.is_some && true_self.value.getVisualClassification() == RoleClassifications.MEDDLER)
			{
				list2.Add(true_self.value);
			}
			if (list3.Count == 0 && true_self.is_some && true_self.value.getVisualClassification().equalToAny(RoleClassifications.UNDERLING, RoleClassifications.TRAITOR))
			{
				list3.Add(true_self.value);
			}
			list4.Add(list[0].getAddress());
			list4.Add(list3[0].getAddress());
			list4.Add((list2.Count == 0) ? (-1) : list2[0].getAddress());
		}
		list4.Sort();
		addresses_said = list4.ToArray();
		return infoString(list4);
	}

	private string infoString(List<int> _addresses)
	{
		if (_addresses[0] != -1)
		{
			return checkTranslationWithReplace(() => getInfoEnglish(_addresses[0], _addresses[1], _addresses[2]), _addresses[0], _addresses[1], _addresses[2]);
		}
		return checkTranslationWithReplace(loc_no_meddler_info_key, () => getInfoNoMeddlerEnglish(_addresses[1].ToString(), _addresses[2].ToString()), _addresses[1], _addresses[2]);
	}

	private string getInfoEnglish(int _data_1, int _data_2, int _data_3)
	{
		return getInfoEnglish(_data_1.ToString(), _data_2.ToString(), _data_3.ToString());
	}

	private string getInfoEnglish(string _data_1, string _data_2, string _data_3)
	{
		return "The forecast today! #" + _data_1 + ", #" + _data_2 + ", #" + _data_3 + ".";
	}

	private string getInfoNoMeddlerEnglish(string _data_2, string _data_3)
	{
		return "The forecast today! No meddler!, #" + _data_2 + ", #" + _data_3 + ".";
	}

	public RoleData createAndForceSetInfo(List<int> _addresses)
	{
		base.info_string = infoString(_addresses).maybe();
		addresses_said = _addresses.ToArray();
		return this;
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
		return $"{addresses_said[0]},{addresses_said[1]},{addresses_said[2]}";
	}
}
