using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Politician : RoleData, IHaveRoleAbility, IHaveAbility
{
	private List<int> targets = new List<int>();

	public override Roles role => Roles.POLITICIAN;

	public override string english_name => "Politician";

	public override string english_description => $"{Keywords.ABILITY.toStringCap()}: Pick {numberTargets} {TextHelper.roles}. I {Keywords.ANNOUNCE.toString()} the majorities {Keywords.ALIGNMENT.toString()}.";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounceOppositeOfTrue) };

	bool IHaveAbility.abilityExhausted => ability_exhausted;

	public int numberTargets => 3;

	bool IHaveRoleAbility.allowSelfTarget => true;

	public override bool has_hover_focus
	{
		get
		{
			if (ability_exhausted)
			{
				return targets.Count > 0;
			}
			return false;
		}
	}

	public override bool hasInfo => ability_exhausted;

	public Politician(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Politician(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			targets = _save.unique_data.fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading failed! {role}. Error: {arg}");
			targets = new List<int>();
		}
	}

	bool IHaveRoleAbility.validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	string IHaveAbility.getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(3);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		targets = _target_addresses.copy();
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (!_occupent.is_a)
		{
			return false;
		}
		return targets.Contains(_occupent.maybe_a.value.getAddress());
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (targets.Count != numberTargets)
		{
			Debug.LogError($"Trying to get info string before targets are selected!!! {role}.");
			return "";
		}
		Dictionary<int, RoleData> in_play = _snap.address_occupents;
		List<RoleData> list = targets.Select((int _a) => in_play[_a]).ToList();
		Alignments alignments = list[0].getVisualAlignment();
		if (alignments != list[1].getVisualAlignment() && alignments != list[2].getVisualAlignment())
		{
			alignments = list[1].getVisualAlignment();
		}
		if (base.has_bad_info)
		{
			alignments = ((alignments == Alignments.GOOD) ? Alignments.EVIL : Alignments.GOOD);
		}
		return getInfo(targets, alignments);
	}

	private string getInfo(List<int> _targets, Alignments _align)
	{
		return checkTranslationWithReplace(() => englishInfo(_targets[0].ToString(), _targets[1].ToString(), _targets[2].ToString(), _align.toString()), () => _targets[0].ToString(), () => _targets[1].ToString(), () => _targets[2].ToString(), () => _align.toString());
	}

	private string englishInfo(string _d1, string _d2, string _d3, string _d4)
	{
		return "#" + _d1 + ", #" + _d2 + ", and #" + _d3 + " are " + _d4 + " folk.";
	}

	public override string getUniqueSaveData()
	{
		return targets.ToString();
	}
}
