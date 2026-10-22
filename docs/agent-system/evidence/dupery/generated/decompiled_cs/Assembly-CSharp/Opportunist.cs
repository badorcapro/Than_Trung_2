using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Opportunist : CasinoRoleData, IHaveRoleAbility, IHaveAbility
{
	public static int chips_on_the_line = 15;

	private bool gained_chips;

	private int target = -1;

	public override Roles role => Roles.OPPORTUNIST;

	public override string english_name => "Opportunist";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick a " + Keywords.ROLE.toString() + ", if they are an " + RoleClassifications.UNDERLING.toString() + ", " + $"gain {chips_on_the_line} {TextHelper.chips_with_link}, otherwise lose {chips_on_the_line} {TextHelper.chips_with_link}. I {Keywords.ANNOUNCE.toString()} if you gained or lost {Keywords.CHIPS.toString()}.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, $"{TextHelper.whenIAmLyingOrTainted}, you will lose {chips_on_the_line} {TextHelper.chips_with_link} when picking an {TextHelper.underlingRole} and" + $" gain {chips_on_the_line} {TextHelper.chips_with_link} when picking any other {Keywords.ROLE.toString()}. My {TextHelper.announcement} will always be true."));
			return list;
		}
	}

	public override bool hasInfo => ability_exhausted;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public bool allowSelfTarget => true;

	public override bool has_hover_focus => hasInfo;

	private string loc_win_info_key => $"{role} [info_win]";

	private string loc_lose_info_key => $"{role} [info_lose]";

	public Opportunist(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Opportunist(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split(',');
			gained_chips = array[0].StartsWith("t");
			target = int.Parse(array[1]);
		}
		catch (Exception arg)
		{
			Debug.LogError($"Something went wrong parsing save data! Error: {arg}");
			gained_chips = false;
			target = -1;
		}
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(1);
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == target;
		}
		return false;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		if (_target_addresses.Count == 0)
		{
			Debug.LogError($"{role} | No targets!");
			return _board;
		}
		target = _target_addresses[0];
		gained_chips = _board.getRolesInPlay()[target].getVisualClassification() == RoleClassifications.UNDERLING;
		if (base.has_bad_info)
		{
			gained_chips = !gained_chips;
		}
		if (gained_chips)
		{
			base.casino_case.gainChips(chips_on_the_line);
		}
		else
		{
			base.casino_case.spendChips(chips_on_the_line);
		}
		return _board;
	}

	protected override string generateCasinoInfoString(CasinoCaseSnapshot _snap)
	{
		if (gained_chips)
		{
			return checkTranslationWithData(loc_win_info_key, getEnglishWin, target);
		}
		return checkTranslationWithData(loc_lose_info_key, getEnglishLoss, target);
	}

	private string getEnglishWin(string _data)
	{
		return "I won against #" + _data + "!";
	}

	private string getEnglishLoss(string _data)
	{
		return "I lost against #" + _data + "!";
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
		return (gained_chips ? "t" : "f") + $",{target}";
	}
}
