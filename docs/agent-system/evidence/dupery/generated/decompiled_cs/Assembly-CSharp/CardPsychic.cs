using System;
using System.Collections.Generic;
using GRGLib.Extensions;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class CardPsychic : CasinoRoleData, IHaveRoleAbility, IHaveAbility
{
	private const int ability_cost = 1;

	private int target = -1;

	public override Roles role => Roles.CARD_PSYCHIC;

	public override string english_name => "Card Psychic";

	public override string english_description => TextHelper.ability_with_cost_marker + ": Pick a " + Keywords.ROLE.toString() + ", if they are a " + RoleClassifications.MEDDLER.toString() + " or " + RoleClassifications.TRAITOR.toString() + ", I " + Keywords.ANNOUNCE.toString() + " the sum of your " + TextHelper.cardsValues + ". If not, I announce the " + TextHelper.value + " of your lowest " + Keywords.CARD.toString() + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I " + Keywords.ANNOUNCE.toString() + " the " + TextHelper.value + " of your lowest " + Keywords.CARD.toString() + " if you pick a " + RoleClassifications.MEDDLER.toString() + " or " + TextHelper.traitorRole + ". Otherwise I " + Keywords.ANNOUNCE.toString() + " the sum of the " + TextHelper.cardsValues + " in your hand."));
			return list;
		}
	}

	public override bool hasInfo
	{
		get
		{
			if (ability_exhausted)
			{
				return target != -1;
			}
			return false;
		}
	}

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public bool allowSelfTarget => true;

	public CardPsychic(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public CardPsychic(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, Mathf.FloorToInt(1f * (_snapshot as CasinoCaseSnapshot).casino_payload.cost_multi).ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 1.ToString());
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		return true;
	}

	public string getAbilityPrompt()
	{
		return TextHelper.ab_selectRolesLocalised(1);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		base.casino_case.spendChips(Mathf.FloorToInt(1f * base.casino_case.cost_multiplyer));
		target = _target_addresses[0];
		return _board;
	}

	protected override string generateCasinoInfoString(CasinoCaseSnapshot _snap)
	{
		bool flag = _snap.address_occupents[target].getVisualClassification().equalToAny(RoleClassifications.MEDDLER, RoleClassifications.TRAITOR);
		int replace = (((base.has_bad_info && flag) || (!base.has_bad_info && !flag)) ? Mathf.Min(_snap.casino_payload.left_card.value, _snap.casino_payload.right_card.value) : (Mathf.Min(_snap.casino_payload.left_card.value, 10) + Mathf.Min(_snap.casino_payload.right_card.value, 10)));
		return checkTranslationWithData(englishInfo, replace);
	}

	private string englishInfo(string _data)
	{
		return "The cards read " + _data + ".";
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
		return "";
	}
}
