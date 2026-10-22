using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Informant : CasinoRoleData
{
	public const int chips_threshold = 50;

	private int target_1 = -1;

	private int target_2 = -1;

	private bool target_forced;

	public override Roles role => Roles.INFORMANT;

	public override string english_name => "Informant";

	public override string english_description => "I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of 2 " + TextHelper.roles + ". One of them is " + Alignments.GOOD.toString() + ", the other is " + Alignments.EVIL.toString() + ". " + $"If you have fewer than {50} {Keywords.CHIPS.toString()}, {TextHelper.investigating} these {TextHelper.roles} is free.\nStarts {TextHelper.investigated}.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I start " + TextHelper.investigated + " even when I am " + TextHelper.lying + " or " + TextHelper.tainted + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I will " + Keywords.ANNOUNCE.toString() + " the " + TextHelper.addresses + " of 2 " + TextHelper.goodRoles + " and " + TextHelper.investigating + " them will not be free."));
			return list;
		}
	}

	public override bool hasInfo => true;

	public override bool has_hover_focus => true;

	public Informant(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Informant(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			target_1 = int.Parse(array[0]);
			target_2 = int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Something went wrong parsing save data! Error: {arg}");
			target_1 = -1;
			target_2 = -1;
		}
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress().equalToAny(target_1, target_2);
		}
		return false;
	}

	protected override string generateCasinoInfoString(CasinoCaseSnapshot _snap)
	{
		if (target_forced)
		{
			return getInfo();
		}
		Dictionary<int, RoleData> address_occupents = _snap.address_occupents;
		IEnumerable<RoleData> source = address_occupents.Values.Where((RoleData _r) => !_r.getIsInvestigated());
		List<RoleData> list = source.Where((RoleData _r) => _r.getVisualAlignment() == Alignments.GOOD).ToList();
		if (base.has_bad_info)
		{
			if (list.Count < 2)
			{
				list = address_occupents.Values.Where((RoleData _r) => _r.getVisualAlignment() == Alignments.GOOD).ToList();
				if (list.Count < 2)
				{
					Debug.LogError("Informant could not find 2 good roles!!!");
					return "";
				}
			}
			List<int> list2 = (from _t in list.getRandomElementsFromList(random, 2)
				select _t.getAddress()).ToList();
			list2.Sort();
			target_1 = list2[0];
			target_2 = list2[1];
			return getInfo();
		}
		List<RoleData> list3 = source.Where((RoleData _r) => _r.getVisualAlignment() == Alignments.EVIL).ToList();
		if (list.Count == 0)
		{
			list = address_occupents.Values.Where((RoleData _r) => _r.getVisualAlignment() == Alignments.GOOD).ToList();
		}
		if (list3.Count == 0)
		{
			list3 = address_occupents.Values.Where((RoleData _r) => _r.getVisualAlignment() == Alignments.EVIL).ToList();
		}
		if (list3.Count == 0 || list.Count == 0)
		{
			Debug.LogError("NO GOOD/BAD roles found!!! This shouldnt be possible!");
			return "";
		}
		target_1 = list.getRandomElementFromList(random).getAddress();
		target_2 = list3.getRandomElementFromList(random).getAddress();
		if (target_1 > target_2)
		{
			int num = target_1;
			target_1 = target_2;
			target_2 = num;
		}
		return getInfo();
	}

	private string getInfo()
	{
		return checkTranslationWithReplace(() => getInfoEnglish(target_1.ToString(), target_2.ToString()), target_1, target_2);
	}

	private string getInfoEnglish(string _data_1, string _data_2)
	{
		return "Be careful of #" + _data_1 + " and #" + _data_2 + "!";
	}

	public void createAndForceSetInfo(int _t1, int _t2)
	{
		target_1 = _t1;
		target_2 = _t2;
		target_forced = true;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		base.investigated = true;
		if (!base.obscured)
		{
			base.case_ref.checkAddSuspect(role);
		}
		return _board;
	}

	public override int fetchInvistigationCost(int _investigating_address, int _cost, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CasinoCaseActionPayload _payload)
	{
		if (!base.has_bad_info && _payload.chips < 50 && _investigating_address.equalToAny(target_1, target_2))
		{
			return 0;
		}
		return _cost;
	}

	public override string getUniqueSaveData()
	{
		return $"{target_1},{target_2}";
	}
}
