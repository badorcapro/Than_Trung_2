using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class Snitch : CasinoRoleData, IHaveRoleAbility, IHaveAbility
{
	private const int ability_cost = 25;

	public override Roles role => Roles.SNITCH;

	public override string english_name => "Snitch";

	public override string english_description => TextHelper.ability_with_cost_marker + ": I " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of a random " + TextHelper.evilRole + ". You must " + Keywords.ARREST.toString() + " me to use my ability. " + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "I can " + Keywords.ANNOUNCE.toString() + " the " + Keywords.ADDRESS.toString() + " of any " + TextHelper.evilRole + " including " + TextHelper.roles + " that are " + TextHelper.arrested + " or " + Keywords.DEAD.toString() + "."));
			return list;
		}
	}

	public bool abilityExhausted
	{
		get
		{
			if (!ability_exhausted && !base.tainted)
			{
				return !base.arrested;
			}
			return true;
		}
	}

	public int numberTargets => 1;

	public bool allowSelfTarget => true;

	public override bool hasInfo
	{
		get
		{
			if (ability_exhausted && !base.tainted)
			{
				return base.arrested;
			}
			return false;
		}
	}

	private string loc_info_no_key => $"{role} [info_no]";

	public Snitch(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public Snitch(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, Mathf.FloorToInt(25f * (_snapshot as CasinoCaseSnapshot).casino_payload.cost_multi).ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 25.ToString());
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HAS_ABILITY, new ClassificationRatioGC(RoleClassifications.UNDERLING, 2));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		return _roll_candidate.getAddress() == base.address;
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_reselectToConfirmLocalised;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (base.tainted || !base.arrested)
		{
			return _board;
		}
		if (_ability_user_address == base.address)
		{
			base.casino_case.spendChips(Mathf.FloorToInt(25f * (_payload as CasinoCaseActionPayload).cost_multi));
		}
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (base.tainted)
		{
			return _board;
		}
		if (_arrested_address == base.address)
		{
			setDisguise(new Maybe<RoleData>());
			if (abilityExhausted)
			{
				ability_exhausted = false;
			}
		}
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		List<RoleData> list = _snap.board.getRolesInPlay().Values.Where((RoleData _r) => _r.getVisualAlignment() == Alignments.EVIL && _r.getAddress() != base.address).ToList();
		if (list.Count == 0)
		{
			return checkTranslation(loc_info_no_key, infoNoEvilEnglish);
		}
		return checkTranslationWithData(infoEnglish, list.getRandomElementFromList(random).getAddress());
	}

	private string infoEnglish(string _data)
	{
		return "#" + _data + " is the real evil one!";
	}

	private string infoNoEvilEnglish()
	{
		return "I am the only one!";
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
