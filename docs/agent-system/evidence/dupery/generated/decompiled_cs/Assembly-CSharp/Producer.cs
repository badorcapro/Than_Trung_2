using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Producer : RoleData, IHaveRoleAbility, IHaveAbility
{
	private List<int> selected_roles = new List<int>();

	private bool statement;

	public override Roles role => Roles.PRODUCER;

	public override string english_name => "Producer";

	public override string english_description => Keywords.ABILITY.toStringCap() + ": Pick 3 " + TextHelper.roles + ". If they are an " + RoleClassifications.INNOCENT.toString() + ", a " + RoleClassifications.MEDDLER.toString() + " and either an " + RoleClassifications.UNDERLING.toString() + " or " + RoleClassifications.TRAITOR.toString() + ", I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_1 + "\". Otherwise I " + Keywords.ANNOUNCE.toString() + " \"" + RoleData.loc_marker_2 + "\"";

	public override List<(DescriptionType, string)> english_extra_descriptions => new List<(DescriptionType, string)> { (DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTaintIAnnounce + " the wrong statement.") };

	public bool allowSelfTarget => true;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 3;

	public override bool hasInfo => ability_exhausted;

	public override bool has_hover_focus => true;

	private string loc_wrong_key => $"{role} [iw]";

	public Producer(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Producer(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split('#');
			statement = array[0] == "t";
			selected_roles = array[1].fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Failed to load {role}! ({_save.unique_data})\nError: {arg}");
			statement = false;
			selected_roles = new List<int>();
		}
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(numberTargets);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (statement)
		{
			if (base.has_bad_info)
			{
				return checkTranslation(loc_wrong_key, englishCut);
			}
			return checkTranslation(englishWrap);
		}
		if (base.has_bad_info)
		{
			return checkTranslation(englishWrap);
		}
		return checkTranslation(loc_wrong_key, englishCut);
	}

	private string englishWrap()
	{
		return "That's a wrap";
	}

	private string englishCut()
	{
		return "Cut cut cut!";
	}

	public override bool checkHoverFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return selected_roles.Contains(_occupent.maybe_a.value.getAddress());
		}
		return false;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (base.address != _ability_user_address)
		{
			return _board;
		}
		Dictionary<int, RoleData> in_play = _board.getRolesInPlay();
		selected_roles = _target_addresses.copy();
		statement = selected_roles.Any((int _a) => in_play[_a].getVisualClassification() == RoleClassifications.INNOCENT) && selected_roles.Any((int _a) => in_play[_a].getVisualClassification() == RoleClassifications.MEDDLER) && selected_roles.Any((int _a) => in_play[_a].getVisualClassification().equalToAny(RoleClassifications.UNDERLING, RoleClassifications.TRAITOR));
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	public override string getUniqueSaveData()
	{
		return (statement ? "t" : "f") + "#" + selected_roles.toStringCommaSeperated();
	}
}
