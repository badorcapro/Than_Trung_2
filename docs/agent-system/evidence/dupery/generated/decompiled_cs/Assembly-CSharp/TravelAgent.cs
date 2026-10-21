using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using Save;
using UnityEngine;

public class TravelAgent : RoleData
{
	private int stopped_investigation = -1;

	public override Roles role => Roles.TRAVEL_AGENT;

	public override string english_name => "Travel Agent";

	public override string english_description => "While I am " + TextHelper.aliveAndNotArrested + ", you cannot " + Keywords.INVESTIGATE.toString() + " the last " + Keywords.UNINVESTIGATED.toString() + " " + Keywords.ROLE.toString() + ". " + TextHelper.iLieAndPretendSuspected + ".";

	public override List<(DescriptionType, string)> english_extra_descriptions
	{
		get
		{
			List<(DescriptionType, string)> list = new List<(DescriptionType, string)>();
			list.Add((DescriptionType.LYING_OR_TAINTED, TextHelper.whenIAmTainted + ", I do not stop you from " + TextHelper.investigating + " the last " + Keywords.UNINVESTIGATED.toString() + " " + Keywords.ROLE.toString() + "."));
			return list;
		}
	}

	public override bool hasInfo => false;

	public override bool has_truth_hover_focus => stopped_investigation != -1;

	public TravelAgent(int _address, Vector2Int _board_position, System.Random _random, Maybe<RoleData> _true_self)
		: base(_address, _board_position, _random, _true_self)
	{
	}

	public TravelAgent(RoleDataSave _save, Maybe<RoleInfoSave> _info, Maybe<RoleDataSave> _disguise, System.Random _random, Func<RoleDataSave, RoleData> _from_save)
		: base(_save, _info, _disguise, _random, _from_save)
	{
		stopped_investigation = int.Parse(_save.unique_data);
	}

	public override RoleGenerationConstraints getGenerationConstraints()
	{
		return new RoleGenerationConstraints(RoleGenerationMarkers.INVESTIGATION_BLOCKER, new AvoidInPlayRoleTypeGC(RoleGenerationMarkers.INVESTIGATION_BLOCKER, DisguiseConstraintType.IGNORE_WHEN_LYING));
	}

	protected override DisguiseCharacteristics generateDisguiseCharacteristics(Case _case_ref)
	{
		return CaseHelper.getGoodDisguise(DisguiseTarget.SUSPECTED);
	}

	public override string generateInfoString(CaseSnapshot _snap)
	{
		throw new NotImplementedException();
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onKillAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _murdered_address, Maybe<RoleData> _killer)
	{
		if (stopped_investigation == -1 || _murdered_address != base.address)
		{
			return _board;
		}
		_board.getRolesInPlay()[stopped_investigation].setCanBeInvestigated($"#R_{role}", _true: true);
		return base.onKillAction(_board, _payload, _murdered_address, _killer);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onArrestAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _arrested_address)
	{
		if (stopped_investigation == -1 || _arrested_address != base.address)
		{
			return _board;
		}
		_board.getRolesInPlay()[stopped_investigation].setCanBeInvestigated($"#R_{role}", _true: true);
		return base.onArrestAction(_board, _payload, _arrested_address);
	}

	protected override Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> onInvestigationAction(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, CaseActionPayload _payload, int _investigated_address)
	{
		checkForInvestigationBlocking(_board, _investigated_address);
		return _board;
	}

	private void checkForInvestigationBlocking(Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, int _address)
	{
		if (base.tainted || base.arrested || base.dead || stopped_investigation != -1)
		{
			return;
		}
		List<RoleData> list = _board.getRolesInPlay().Values.Where((RoleData _r) => !_r.getIsInvestigated() && !_r.getIsDead() && !_r.getIsArrested()).ToList();
		if (list.Count == 0)
		{
			if (_address != -1)
			{
				RoleData roleData = _board.getRolesInPlay()[_address];
				roleData.setCanBeInvestigated($"#R_{roleData}", _true: false);
				stopped_investigation = _address;
				if (!roleData.canBeInvestigated(_board))
				{
					roleData.uninvestigateOuter();
				}
			}
		}
		else if (list.Count == 1)
		{
			stopped_investigation = list[0].getAddress();
			list[0].setCanBeInvestigated($"#R_{role}", _true: false);
		}
	}

	public override string getUniqueSaveData()
	{
		return stopped_investigation.ToString();
	}

	public override string getTruthString()
	{
		return ((stopped_investigation == -1) ? "" : (TextHelper.blockedOneLocalised(stopped_investigation) + "\n")) + base.getTruthString();
	}

	public override bool checkEndHoverTruthFocus(CaseSnapshot _snap, Vector2Int _position, Either<RoleData, LocationData> _occupent)
	{
		if (_occupent.is_a)
		{
			return _occupent.maybe_a.value.getAddress() == stopped_investigation;
		}
		return false;
	}
}
