using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Chauffeur : CasinoRoleData, IHaveRoleAbility, IHaveAbility
{
	private const int ability_cost = 2;

	public int address_picked = -1;

	public override Roles role => Roles.CHAUFFEUR;

	public override string english_name => "Chauffeur";

	public override string english_description => TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.ROLE.toString() + ". If that " + Keywords.ROLE.toString() + " is " + TextHelper.tainted + ", I " + Keywords.ANNOUNCE.toString() + " what they should have said. Otherwise I " + Keywords.ANNOUNCE.toString() + " that they are not " + TextHelper.tainted + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I only check if a " + Keywords.ROLE.toString() + " is " + TextHelper.tainted + ", not if they are " + TextHelper.lying + "."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", if you picked a " + TextHelper.taintedRole + ", I " + Keywords.ANNOUNCE.toString() + " that they are not " + TextHelper.tainted + ". Otherwise I " + Keywords.ANNOUNCE.toString() + " what they would have said if they were " + TextHelper.tainted + "."));
			return list;
		}
	}

	public override bool hasInfo => ability_exhausted;

	bool IHaveAbility.abilityExhausted => ability_exhausted;

	int IHaveAbility.numberTargets => 1;

	bool IHaveRoleAbility.allowSelfTarget => true;

	private string loc_no_info_key => $"{role} [no_info]";

	public Chauffeur(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Chauffeur(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		address_picked = int.Parse(_save.unique_data);
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, Mathf.FloorToInt(2f * (_snapshot as CasinoCaseSnapshot).casino_payload.cost_multi).ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 2.ToString());
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address == base.address)
		{
			address_picked = _target_addresses[0];
			base.casino_case.spendChips(Mathf.FloorToInt(2f * base.casino_case.cost_multiplyer));
		}
		return _board;
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		RoleData visualRole = _snap.board.getRolesInPlay()[address_picked].getVisualRole();
		if (visualRole.getIsTainted())
		{
			if (!base.has_bad_info)
			{
				return getTargetTaintedInfoString(visualRole, _snap);
			}
			return getTargetNotTaintedInfoString(address_picked);
		}
		if (!base.has_bad_info)
		{
			return getTargetNotTaintedInfoString(address_picked);
		}
		return getTargetTaintedInfoString(visualRole, _snap);
	}

	private string getTargetTaintedInfoString(RoleData _role, CaseSnapshot _snap)
	{
		RoleData roleData = _role.role.createRole(_role.getAddress(), _role.getBoardPosition(), random, new Maybe<RoleData>());
		roleData.setCaseRef(base.case_ref);
		if (!roleData.hasInfo)
		{
			return checkTranslation(loc_no_info_key, getNoInfoEnglish);
		}
		roleData.setTainted(base.has_bad_info);
		return roleData.generateInfoString(_snap);
	}

	private string getTargetNotTaintedInfoString(int _address)
	{
		return checkTranslationWithData(getTargetNotTaintedInfoEnglish, _address);
	}

	private string getTargetNotTaintedInfoEnglish(string _data)
	{
		return "#" + _data + " is not tainted.";
	}

	private string getNoInfoEnglish()
	{
		return "*No Info*";
	}

	bool IHaveRoleAbility.validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	string IHaveAbility.getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(1);
	}

	public override string getUniqueSaveData()
	{
		return address_picked.ToString();
	}
}
