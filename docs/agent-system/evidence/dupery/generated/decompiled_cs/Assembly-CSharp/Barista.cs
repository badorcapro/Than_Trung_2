using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Barista : CasinoRoleData, IHaveRoleAbility, IHaveAbility
{
	private const int ability_cost = 2;

	private int tainted_target = -1;

	private int abil_choice = -1;

	public override Roles role => Roles.BARISTA;

	public override string english_name => "Barista";

	public override string english_description => "I " + Keywords.TAINT.toString() + " a " + Keywords.SURROUNDING.toString() + " " + TextHelper.innocentRole + ".\n" + TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.ROLE.toString() + ", I " + Keywords.ANNOUNCE.toString() + " if they are " + TextHelper.tainted + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I do not " + Keywords.TAINT.toString() + " any " + Keywords.ROLE.toString() + " and " + TextHelper.iAnnounceOppositeOfTrue));
			return list;
		}
	}

	public override string credits => "Devy L. & D. Espair";

	public bool allowSelfTarget => false;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public override bool hasInfo
	{
		get
		{
			if (ability_exhausted)
			{
				return abil_choice > 0;
			}
			return false;
		}
	}

	public override bool has_end_info_hover_focus => true;

	private string loc_no_taint_key => $"{role} [info_nt]";

	public Barista(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Barista(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		tainted_target = RoleHelper.tryLoadSingleValueFromUniqueData(role, _save);
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return defaultFillDescription(_description);
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 2.ToString());
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HAS_ABILITY, new PositionRoleGC(RoleClassifications.INNOCENT, GCPosition.SURROUNDING, DisguiseConstraintType.IGNORE_WHEN_LYING)).addMarker(RoleGenerationMarkers.TAINTS);
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		return _roll_candidate.getBoardPosition().isSurroundingOrOn(base.board_position);
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectSurroundingRolesLocalised(numberTargets);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.has_bad_info || base.dead || base.arrested)
		{
			return _board;
		}
		List<RoleData> list = (from _r in _board.getSurroundingRolesFromGridPos(base.board_position, base.case_ref.board_size)
			where _r.getVisualClassification() == RoleClassifications.INNOCENT
			select _r).ToList();
		if (list.Count == 0)
		{
			Debug.LogError($"{role} could not find any valid targets to taint!");
			return _board;
		}
		RoleData randomElementFromList = list.getRandomElementFromList(random);
		randomElementFromList.setTainted(_new: true);
		tainted_target = randomElementFromList.getAddress();
		return base.onRoundStartAction(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		if (_target_addresses.Count < 1)
		{
			Debug.LogError($"{role} Ability target list was empty!");
			return _board;
		}
		abil_choice = _target_addresses[0];
		base.casino_case.spendChips(2);
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (abil_choice == -1)
		{
			Debug.LogError($"{role} trying to generate info before ability has been used!");
			return "";
		}
		bool flag = _snap.address_occupents[abil_choice].getIsTainted();
		if (base.has_bad_info)
		{
			flag = !flag;
		}
		if (flag)
		{
			return checkTranslationWithData(englishInfo, abil_choice);
		}
		return checkTranslationWithData(loc_no_taint_key, englishNotTaintedInfo, abil_choice);
	}

	private string englishInfo(string _data)
	{
		return "#" + _data + " is tainted.";
	}

	private string englishNotTaintedInfo(string _data)
	{
		return "#" + _data + " is not tainted.";
	}

	public override string getTruthString()
	{
		return ((tainted_target == -1) ? "" : (TextHelper.taintedOneLocalised(tainted_target) + "\n")) + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == tainted_target;
		}
		return false;
	}

	public override string getUniqueSaveData()
	{
		return tainted_target.ToString();
	}
}
