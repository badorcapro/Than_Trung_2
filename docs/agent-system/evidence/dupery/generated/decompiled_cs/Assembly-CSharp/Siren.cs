using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Siren : DocksRoleData, IHaveRoleAbility, IHaveAbility
{
	private int ab_target = -1;

	private List<int> tainted_addresses = new List<int>();

	public override Roles role => Roles.SIREN;

	public override string english_name => "Siren";

	public override string english_description => "I " + Keywords.TAINT.toString() + " all " + Keywords.TRUTHFUL.toString() + " " + TextHelper.surroundingNeighbours + ".\n" + Keywords.ABILITY.toStringCap() + ": Pick a " + TextHelper.surroundingNeighbour + ". I make them " + Keywords.TRUTHFUL.toString() + " but " + Keywords.TAINT.toString() + " all other " + Keywords.TRUTHFUL.toString() + " " + TextHelper.roles + " " + Keywords.IN_PLAY.toString() + ". All " + TextHelper.announcement + " are restated. If I am " + TextHelper.arrested + ", my " + Keywords.ABILITY.toString() + " will not work.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "The " + Keywords.ROLE.toString() + " picked with my " + Keywords.ABILITY.toString() + " will immidiatly become " + Keywords.TRUTHFUL.toString() + " but can be " + TextHelper.tainted + " by other " + TextHelper.roles + " later on."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not " + Keywords.TAINT.toString() + " any " + Keywords.ROLE.toString() + " and my " + Keywords.ABILITY.toString() + " will not work."));
			return list;
		}
	}

	bool IHaveAbility.abilityExhausted => ability_exhausted;

	int IHaveAbility.numberTargets => 1;

	bool IHaveRoleAbility.allowSelfTarget => false;

	public override bool hasInfo => ability_exhausted;

	public Siren(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Siren(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		try
		{
			string[] array = _save.unique_data.Split('#');
			ab_target = int.Parse(array[0]);
			tainted_addresses = array[1].fromStringCommaSeperate();
		}
		catch (Exception arg)
		{
			Debug.LogError($"Loading Failed! {role}! ({_save.unique_data}) Error: {arg}");
			ab_target = -1;
			tainted_addresses = new List<int>();
		}
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.TAINTS);
	}

	bool IHaveRoleAbility.validateTarget(RoleData _roll_candidate)
	{
		return _roll_candidate.getBoardPosition().isSurroundingOrOn(base.board_position);
	}

	string IHaveAbility.getAbilityPrompt()
	{
		return checkTranslation(base.loc_default_ability_prompt_key, getAbilityPromptEnglish);
	}

	private string getAbilityPromptEnglish()
	{
		return "Select 1 surrounding role.";
	}

	protected override string generateDocksInfoString(DocksCaseSnapshot _snap)
	{
		if (ab_target == -1)
		{
			Debug.LogError($"Trying to generate info before target has been picked! {role}!");
			return "";
		}
		return checkTranslationWithData(englishInfo, ab_target);
	}

	private string englishInfo(string _data)
	{
		return "I released #" + _data + " from my spell in exchange for everyone else!";
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		ab_target = _target_addresses[0];
		if (base.tainted || base.arrested)
		{
			return _board;
		}
		Dictionary<int, RoleData> rolesInPlay = _board.getRolesInPlay();
		rolesInPlay[ab_target].forceTruth();
		rolesInPlay[ab_target].resetInfo();
		foreach (KeyValuePair<int, RoleData> item in rolesInPlay)
		{
			if (item.Key != base.address && item.Key != ab_target)
			{
				if (!item.Value.getIsLyingOrTainted())
				{
					item.Value.setTainted(_new: true);
				}
				item.Value.resetInfo();
			}
		}
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.arrested || base.dead || base.tainted)
		{
			return _board;
		}
		foreach (RoleData surroundingRolesFromGridPo in _board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size))
		{
			if (!surroundingRolesFromGridPo.getIsLyingOrTainted())
			{
				surroundingRolesFromGridPo.setTainted(_new: true);
				tainted_addresses.Add(surroundingRolesFromGridPo.getAddress());
			}
		}
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	public override string getUniqueSaveData()
	{
		return ab_target + "#" + tainted_addresses.toStringCommaSeperated();
	}

	protected override bool isLiar()
	{
		return false;
	}
}
