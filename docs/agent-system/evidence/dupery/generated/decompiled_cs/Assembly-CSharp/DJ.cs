using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class DJ : CasinoRoleData, IHaveRoleAbility, IHaveAbility
{
	private const int ability_cost = 20;

	public override Roles role => Roles.DJ;

	public override string english_name => "DJ";

	public override string english_description => "I force all " + TextHelper.adjacentNeighbours + " to " + Keywords.PRETEND.toString() + " to be " + Roles.DANCER.toString() + "s. Other " + TextHelper.roles + " cannot " + Keywords.PRETEND.toString() + " to be me.\n" + Keywords.ABILITY.toStringCap() + " [Cost: " + RoleData.loc_marker_1 + TextHelper.chips_sprite_link + "]: I stop the music.";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.SPECIAL, "When I stop the music, all " + TextHelper.adjacentNeighbours + " " + Keywords.REVEAL.toString() + " their true identity."));
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmLyingOrTainted + ", I do nothing."));
			return list;
		}
	}

	public override bool can_be_disguise => false;

	public bool abilityExhausted => ability_exhausted;

	public int numberTargets => 1;

	public bool allowSelfTarget => true;

	public override bool hasInfo => true;

	private string loc_info_after_key => $"{role} [info_aft]";

	public DJ(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public DJ(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
	}

	protected override string fillDescription(string _description, CaseSnapshot _snapshot)
	{
		return _description.Replace(RoleData.loc_marker_1, Mathf.FloorToInt(20f * (_snapshot as CasinoCaseSnapshot).casino_payload.cost_multi).ToString());
	}

	protected override string defaultFillDescription(string _description)
	{
		return _description.Replace(RoleData.loc_marker_1, 20.ToString());
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.HAS_ABILITY, new PositionRoleGC(GCPosition.ADJACENT, DisguiseConstraintType.NEVER_IGNORE));
	}

	public bool validateTarget(RoleData _roll_candidate)
	{
		return _roll_candidate.getAddress() == base.address;
	}

	public string getAbilityPrompt()
	{
		return checkTranslation(base.loc_default_ability_prompt_key, getAbilityPromptEnglish);
	}

	private string getAbilityPromptEnglish()
	{
		return TextHelper.ab_reselectToConfirmLocalised;
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onDisguiseSet(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		if (base.has_bad_info)
		{
			return _board;
		}
		_board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size).ForEach(delegate(RoleData _r)
		{
			_r.setDisguise(Roles.DANCER.createRole(_r.getAddress(), _r.getBoardPosition(), random, _r.maybe()).maybe());
			_r.setForcedDisguised();
		});
		return base.onDisguiseSet(_board, _payload, _suspects);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onAbilityUsedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _ability_user_address, List<int> _target_addresses)
	{
		if (_ability_user_address != base.address)
		{
			return _board;
		}
		base.casino_case.spendChips(Mathf.FloorToInt(20f * base.casino_case.cost_multiplyer));
		if (base.has_bad_info)
		{
			return _board;
		}
		_board.getAdjacentRolesFromGridPos(base.board_position, base.case_ref.board_size).ForEach(delegate(RoleData _r)
		{
			if (!_r.getIsDead() && !_r.getIsArrested())
			{
				_r.setDisguise(new Maybe<RoleData>());
			}
		});
		base.info_string = new Maybe<string>();
		return base.onAbilityUsedAction(_board, _payload, _ability_user_address, _target_addresses);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		if (abilityExhausted)
		{
			return checkTranslation(loc_info_after_key, infoAfterEnglish);
		}
		return checkTranslation(infoEnglish);
	}

	private string infoEnglish()
	{
		return "You want me to stop the music?!";
	}

	private string infoAfterEnglish()
	{
		return "Sorry everyone. Party's over.";
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.GOOD;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.MEDDLER;
	}

	public override string getUniqueSaveData()
	{
		return "";
	}
}
