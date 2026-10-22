using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class RatKing : ClockRoleData
{
	private int trigger_target = 3;

	private int moving_trigger_time = 3;

	private List<int> previous_victims = new List<int>();

	public override Roles role => Roles.RAT_KING;

	public override string english_name => "Rat King";

	public override string english_description => "I " + Keywords.TRANSFORM.toString() + " a random " + TextHelper.innocentRole + " into a " + Roles.RAT.toString() + ". " + $"Every {trigger_target} hours, I {Keywords.TRANSFORM.toString()} another {Keywords.ROLE} into a {Roles.RAT.toString()}.\n{TextHelper.iLieAndPretendNotInPlay}.";

	public override bool hasInfo => false;

	public RatKing(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		moving_trigger_time = int.Parse(_save.unique_data);
	}

	public RatKing(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.NOT_IN_PLAY);
	}

	public override string getTruthString()
	{
		return checkTranslation(base.loc_default_truth_key, getTruthEnglish) + "\n" + base.getTruthString();
	}

	private string getTruthEnglish()
	{
		return "RATS!";
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	public override string getUniqueSaveData()
	{
		return moving_trigger_time.ToString();
	}

	protected override Alignments getStartingAlignment()
	{
		return Alignments.EVIL;
	}

	protected override RoleClassifications getStartingClassification()
	{
		return RoleClassifications.TRAITOR;
	}

	private Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> increaseTheRatArmy(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board)
	{
		List<RoleData> list = _board.getRolesInPlay().Values.Where((RoleData _e) => _e.getAddress() != base.address && !_e.getIsInvestigated() && _e.role != Roles.RAT).ToList();
		if (list.Count == 0)
		{
			return _board;
		}
		RoleData randomElementFromList = list.getRandomElementFromList(random);
		RoleData roleData = Roles.RAT.createRole(randomElementFromList.getAddress(), randomElementFromList.getBoardPosition(), random, new Maybe<RoleData>());
		roleData.setCaseRef(base.case_ref);
		(roleData as Rat).setVictim(randomElementFromList);
		previous_victims.Add(roleData.getAddress());
		return _board.registerRoleChange(roleData.getBoardPosition(), roleData);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onRoundStartAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, List<RoleData> _suspects)
	{
		return increaseTheRatArmy(_board);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onTimePassedAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _rep, int _new_time)
	{
		if ((base.tainted || base.dead || base.arrested) && !base.case_ref.hasMarkerQuirk(CaseQuirks.HAUNTED))
		{
			return _board;
		}
		previous_victims = new List<int>();
		while (_new_time >= moving_trigger_time)
		{
			_board = increaseTheRatArmy(_board);
			moving_trigger_time += trigger_target;
		}
		if (previous_victims.Count > 0)
		{
			base.clock_case.roleChangeDuringTimePass(previous_victims);
		}
		return _board;
	}
}
