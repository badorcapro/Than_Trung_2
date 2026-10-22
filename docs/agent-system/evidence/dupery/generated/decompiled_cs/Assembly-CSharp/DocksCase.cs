using System;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Maybe;
using GameStats;
using Leads;
using LevelEditor;
using Quirks;
using Save;
using UnityEngine;

public class DocksCase : Case
{
	public static int max_reputation = 6;

	protected CaseReputationManager reputation_manager;

	protected bool player_ended;

	protected bool player_ended_early;

	protected int escaped_evils;

	private int fuel_used;

	private List<Action<DocksBoat>> on_boat_created = new List<Action<DocksBoat>>();

	public override CaseType case_type => CaseType.DOCKS;

	public int reputation
	{
		get
		{
			return reputation_manager.reputation;
		}
		protected set
		{
			reputation_manager.reputation = value;
		}
	}

	public ReputationStatus reputation_status => reputation_manager.calculateVisualReputationStatus(board);

	public ReputationStatus true_reputation_status => reputation.getTrueReputationStatus();

	protected string reputation_comment => reputation_manager.reputation_comment;

	public DocksBoat boat { get; private set; }

	public int arrested_evils { get; private set; }

	public bool anyEscapedEvils => escaped_evils > 0;

	public DocksCase(Lead _lead, int _reputation, int _fuel, float _diff, CaseRatioBuilderData _ratio_data)
		: base(_lead, _diff, _ratio_data)
	{
		reputation_manager = new CaseReputationManager(_reputation, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		createBoardAndStart(_lead, _ratio_data);
		boat = new DocksBoat(_fuel, board.getLocationsInPlay()[LocationTypes.DOCKS].getBoardPosition());
		on_boat_created.ForEach(delegate(Action<DocksBoat> _ac)
		{
			_ac(boat);
		});
	}

	public DocksCase(int _reputation, CaseBuildData _case_data, List<Roles> _available_roles)
		: base(_case_data)
	{
		if (!(_case_data is DocksCaseBuildData docksCaseBuildData))
		{
			Debug.LogError("Cannot create docks case without a Docks Case Build Data!");
			return;
		}
		reputation_manager = new CaseReputationManager(_reputation, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		createBoardAndStart(_available_roles, _case_data.case_quirks);
		boat = new DocksBoat(docksCaseBuildData.calculateStartingFuel(classification_ratio, random), board.getLocationsInPlay()[LocationTypes.DOCKS].getBoardPosition());
		on_boat_created.ForEach(delegate(Action<DocksBoat> _ac)
		{
			_ac(boat);
		});
	}

	public DocksCase(CaseSave _case, Maybe<Lead> _current_lead)
		: base(_case, _current_lead)
	{
		try
		{
			string[] array = _case.unique_data.Split(',');
			reputation_manager = new CaseReputationManager(int.Parse(array[0]), base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
			boat = new DocksBoat(array[1]);
			fuel_used = int.Parse(array[2]);
			if (array[3] == "t")
			{
				reputation_manager.hideReputation("");
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Trying to parse in reputation and boat data failed! Error below.\n{arg}");
			reputation_manager = new CaseReputationManager(5, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
			boat = new DocksBoat(1, board.getLocationsInPlay()[LocationTypes.DOCKS].getBoardPosition());
		}
		on_boat_created.ForEach(delegate(Action<DocksBoat> _ac)
		{
			_ac(boat);
		});
	}

	public DocksCase(Vector2Int _board_size, int _reputation, int _fuel, List<Roles> _suspect_list, List<RoleData> _board_roles, List<LocationData> _board_locations, Maybe<int> _tutorial)
		: base(_board_size, _suspect_list, _board_roles, _board_locations, _tutorial)
	{
		reputation_manager = new CaseReputationManager(_reputation, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		startFromPresetBoard();
		boat = new DocksBoat(_fuel, board.getLocationsInPlay()[LocationTypes.DOCKS].getBoardPosition());
		on_boat_created.ForEach(delegate(Action<DocksBoat> _ac)
		{
			_ac(boat);
		});
	}

	public DocksCase(int _reputation, int _fuel, List<Roles> _suspect_list, List<RoleData> _board_roles, List<LocationData> _board_locations, Maybe<int> _tutorial, Dictionary<RoleClassifications, int> _forced_ratio)
		: base(new Vector2Int(4, 4), _suspect_list, _board_roles, _board_locations, _tutorial, _forced_ratio)
	{
		reputation_manager = new CaseReputationManager(_reputation, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		startFromPresetBoard();
		boat = new DocksBoat(_fuel, board.getLocationsInPlay()[LocationTypes.DOCKS].getBoardPosition());
		on_boat_created.ForEach(delegate(Action<DocksBoat> _ac)
		{
			_ac(boat);
		});
	}

	public DocksCase(LevelEditorManager _manager, Vector2Int _board_size)
		: base(_manager, _board_size)
	{
		reputation_manager = new CaseReputationManager(5, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		boat = new DocksBoat(100, new Vector2Int(-1, -1));
	}

	public DocksCase(DocksCase _editor_case)
		: base(_editor_case)
	{
		reputation_manager = new CaseReputationManager(_editor_case.reputation, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		startFromPresetBoard();
		boat = new DocksBoat(_editor_case.boat.fuel, _editor_case.boat.position);
		on_boat_created.ForEach(delegate(Action<DocksBoat> _ac)
		{
			_ac(boat);
		});
	}

	public DocksCase(int _reputation, int _starting_fuel, float _difficulty_01, List<CaseQuirks> _case_quirks, List<Roles> _forced_roles, int _forced_address_size = -1, int _forced_innocents = -1, int _forced_meddlers = -1, int _forced_underlings = -1, int _forced_traitors = -1, bool _remove_extra_suspects = false)
		: base(new Vector2Int(4, 4), _difficulty_01, _forced_address_size, _forced_innocents, _forced_meddlers, _forced_underlings, _forced_traitors, _remove_extra_suspects)
	{
		reputation_manager = new CaseReputationManager(_reputation, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		createBoardAndStart(new List<Roles>(), _forced_roles, _case_quirks);
		boat = new DocksBoat(_starting_fuel, board.getLocationsInPlay()[LocationTypes.DOCKS].getBoardPosition());
		on_boat_created.ForEach(delegate(Action<DocksBoat> _ac)
		{
			_ac(boat);
		});
	}

	public void doBoatConstructorAction(Action<DocksBoat> _action)
	{
		on_boat_created.Add(_action);
	}

	public override CaseActionPayload getPayload()
	{
		return new DocksCaseActionPayload(reputation, boat, board.getAllArrestedRoles().Count((RoleData _r) => _r.getTrueAlignment() == Alignments.EVIL), !board.getAllNotArrestedOrDeadEvil().Any((RoleData _r) => _r.role.getClassificationFromRoleType() == RoleClassifications.TRAITOR));
	}

	public override CaseSnapshot arrestAddress(int _address)
	{
		if (boat.position != board.getRolesInPlay()[_address].getBoardPosition())
		{
			Debug.Log("In Docks region, cannot arrest a role that is not on the boat!");
			return snapshot();
		}
		return base.arrestAddress(_address);
	}

	protected override void onArrest(RoleData _arrested_role, List<RoleData> _ordered_roles_for_event_calls)
	{
		reputation_manager.onArrest(board, _arrested_role, _ordered_roles_for_event_calls);
	}

	public CaseSnapshot finishCase()
	{
		player_ended = true;
		callRoleFunction(board.getOrderdRolesForEventCalls(), (IAmDocksRole _d, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _b) => _d.onPlayerEnd(_b, getPayload() as DocksCaseActionPayload));
		List<RoleData> allNotArrestedOrDeadEvil = board.getAllNotArrestedOrDeadEvil();
		arrested_evils = board.getAllArrestedRoles().Count((RoleData _r) => _r.getTrueAlignment() == Alignments.EVIL);
		if (allNotArrestedOrDeadEvil.Any((RoleData _r) => _r.role.getClassificationFromRoleType() == RoleClassifications.TRAITOR))
		{
			base.case_solved = false;
			reputation = 0;
			player_ended_early = true;
		}
		else
		{
			base.case_solved = reputation > 0;
			player_ended_early = !base.case_solved;
			escaped_evils = allNotArrestedOrDeadEvil.Count;
		}
		return snapshot();
	}

	protected override bool solvedSnapAllowed()
	{
		if (!base.case_solved)
		{
			return player_ended;
		}
		return true;
	}

	public void moveBoatExternally(Vector2Int _to_position, int _additional_cost = 0)
	{
		moveBoat(_to_position, boat.fuelCostToPosition(_to_position) + _additional_cost);
	}

	public void setBoatPositionWithHiddenCheck(Vector2Int _to_position)
	{
		if (!(boat.position == _to_position))
		{
			boat.position = _to_position;
			checkRoleHiddenState();
		}
	}

	public CaseSnapshot moveBoat(Vector2Int _to_position)
	{
		moveBoat(_to_position, boat.fuelCostToPosition(_to_position));
		return snapshot();
	}

	private bool moveBoat(Vector2Int _to_position, int _fuel_cost)
	{
		if (boat.position == _to_position)
		{
			return false;
		}
		loseFuel(_fuel_cost);
		Vector2Int previous_pos = boat.position;
		boat.position = _to_position;
		checkRoleHiddenState();
		board.getOrderdLocationsForEventCalls().ForEach(delegate(LocationData _l)
		{
			if (_l is IAmDocksLocation amDocksLocation)
			{
				amDocksLocation.onBoatMoved(this, board, _to_position);
			}
		});
		callRoleFunction(board.getOrderdRolesForEventCalls(), (IAmDocksRole _d, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _b) => _d.onBoatMove(_b, getPayload() as DocksCaseActionPayload, previous_pos, _to_position));
		return true;
	}

	private void checkRoleHiddenState()
	{
		if (board[boat.position].is_some && board[boat.position].value.is_a)
		{
			dredgeRole(board[boat.position].value.maybe_a.value, new Maybe<RoleData>());
		}
	}

	public void addFuel(int _add)
	{
		boat.fuel += _add;
	}

	public void loseFuel(int _reduce)
	{
		int fuel_lost = Mathf.Min(boat.fuel, _reduce);
		boat.fuel -= fuel_lost;
		fuel_used += fuel_lost;
		if (fuel_lost < _reduce)
		{
			reputation -= _reduce - fuel_lost;
		}
		callRoleFunctionCheckOverride(board.getOrderdRolesForEventCalls(), (IAmDocksRole _dr, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _b) => _dr.onFuelUsed(_b, getPayload() as DocksCaseActionPayload, fuel_lost));
		SteamHelper.addToStats(AchiementStats.FUEL_USED, fuel_lost);
	}

	public void setFuelHidden(bool _true = true)
	{
		if (boat == null)
		{
			doBoatConstructorAction(delegate(DocksBoat _b)
			{
				_b.fuel_hidden = _true;
			});
		}
		else
		{
			boat.fuel_hidden = _true;
		}
	}

	public void dredgeRole(RoleData _to_dredge, RoleData _dredger)
	{
		dredgeRole(_to_dredge, _dredger.maybe());
	}

	public void dredgeRole(RoleData _to_dredge, Maybe<RoleData> _dredger)
	{
		if (!_to_dredge.getIsHidden())
		{
			return;
		}
		_to_dredge.setHidden(_new: false);
		foreach (CaseQuirkData item in orderedQuirks((CaseQuirkData _q) => _q.is_dredged_quirk))
		{
			item.onDredgeRole(this, board, _to_dredge, _dredger, random);
		}
		callRoleFunction(board.getOrderdRolesForEventCalls(), (IAmDocksRole _dr, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _b) => _dr.onRoleDredged(_b, getPayload() as DocksCaseActionPayload, _to_dredge, _dredger));
		if (!_to_dredge.getIsHidden())
		{
			SteamHelper.addToStats(AchiementStats.ROLES_DREDGED, 1);
		}
	}

	public void setReputationExternally(int _new_rep, string _headline = "")
	{
		reputation_manager.setReputationExternally(_new_rep, _headline);
	}

	public void addReputation(int _add)
	{
		reputation_manager.addReputation(_add);
	}

	public void setHiddenReputation(string _headline = "")
	{
		reputation_manager.hideReputation(_headline);
	}

	public void unhideReputation()
	{
		reputation_manager.unhideReputation();
	}

	protected override void checkForAchievements(bool _won)
	{
		base.checkForAchievements(_won);
		if (_won && (float)boat.fuel >= (float)boat.max_fuel / 2f)
		{
			SteamHelper.tryAchieve(Achiements.ECOLOGIST);
		}
	}

	protected override CaseSnapshot generateCaseSnapshot(bool _silent = false)
	{
		return new DocksCaseSnapshot(getPayload() as DocksCaseActionPayload, player_ended, _silent ? classification_ratio : public_classification_ratio, _silent ? suspect_list : visual_suspect_list, suspect_list, board, reputation_status, reputation_manager, player_ended_early);
	}

	protected override CaseStats setRegionStats()
	{
		return new DocksCaseStats(fuel_used, (from _r in board.getRolesInPlay()
			where _r.Value.getTrueAlignment() == Alignments.EVIL && !_r.Value.getIsArrested() && !_r.Value.getIsDead()
			select _r.Value.role).ToList());
	}

	protected override string getUniqueSaveData()
	{
		return string.Format("{0},{1},{2},{3}", reputation, boat.toSave(), fuel_used, reputation_manager.hidden_reputation ? "t" : "f");
	}

	public void setReputationFromLevelEditor(LevelEditorManager _manager, int _rep)
	{
		reputation_manager.setReputationFromLevelEditor(_manager, _rep);
	}

	public void setReputationFromCBCLead(CaseToCaseLead _lead, int _rep)
	{
		reputation_manager.setReputationFromCBCLead(_lead, _rep);
	}

	public void setFuelFromLevelEditor(LevelEditorManager _manager, int _fuel)
	{
		if (!(_manager == null))
		{
			boat.fuel = _fuel;
		}
	}
}
