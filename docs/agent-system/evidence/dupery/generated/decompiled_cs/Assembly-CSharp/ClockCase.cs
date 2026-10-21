using System;
using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GameStats;
using Leads;
using LevelEditor;
using Quirks;
using Save;
using UnityEngine;

public class ClockCase : Case
{
	public static int max_reputation = 6;

	protected CaseReputationManager reputation_manager;

	protected int hours_passed;

	public override CaseType case_type => CaseType.CLOCK;

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

	public ClockCase(Lead _lead, int _reputation, float _diff, CaseRatioBuilderData _ratio_data)
		: base(_lead, _diff, _ratio_data)
	{
		hours_passed = 0;
		reputation_manager = new CaseReputationManager(_reputation, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		createBoardAndStart(_lead, _ratio_data);
	}

	public ClockCase(int _reputation, CaseBuildData _case_data, List<Roles> _available_roles)
		: base(_case_data)
	{
		hours_passed = 0;
		reputation_manager = new CaseReputationManager(_reputation, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		createBoardAndStart(_available_roles, _case_data.case_quirks);
	}

	public ClockCase(CaseSave _case, Maybe<Lead> _current_lead)
		: base(_case, _current_lead)
	{
		try
		{
			string[] array = _case.unique_data.Split(',');
			reputation_manager = new CaseReputationManager(int.Parse(array[0]), base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
			hours_passed = int.Parse(array[1]);
			if (array[2] == "t")
			{
				reputation_manager.hideReputation("");
			}
		}
		catch (Exception arg)
		{
			Debug.LogError($"Trying to parse in reputation and hours passed failed! ({_case.unique_data}) Error below.\n{arg}");
			reputation_manager = new CaseReputationManager(5, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
			hours_passed = 0;
		}
		onCaseLoadEnd();
	}

	public ClockCase(Vector2Int _board_size, int _reputation, List<Roles> _suspect_list, List<RoleData> _board_roles, List<LocationData> _board_locations, Maybe<int> _tutorial, Dictionary<RoleClassifications, int> _forced_ratio)
		: base(_board_size, _suspect_list, _board_roles, _board_locations, _tutorial, _forced_ratio)
	{
		reputation_manager = new CaseReputationManager(_reputation, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		hours_passed = 0;
		startFromPresetBoard();
	}

	public ClockCase(Vector2Int _board_size, int _reputation, List<Roles> _suspect_list, List<RoleData> _board_roles, List<LocationData> _board_locations, Maybe<int> _tutorial, List<CaseQuirks> _case_quirks = null)
		: base(_board_size, _suspect_list, _board_roles, _board_locations, _tutorial, _case_quirks)
	{
		reputation_manager = new CaseReputationManager(_reputation, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		hours_passed = 0;
		startFromPresetBoard();
	}

	public ClockCase(LevelEditorManager _manager, Vector2Int _board_size)
		: base(_manager, _board_size)
	{
		reputation_manager = new CaseReputationManager(5, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		hours_passed = 0;
	}

	public ClockCase(ClockCase _editor_case)
		: base(_editor_case)
	{
		reputation_manager = new CaseReputationManager(_editor_case.reputation, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		hours_passed = 0;
		startFromPresetBoard();
	}

	public ClockCase(int _reputation, float _difficulty_01, List<CaseQuirks> _case_quirks, List<Roles> _forced_roles, int _forced_address_size = -1, int _forced_innocents = -1, int _forced_meddlers = -1, int _forced_underlings = -1, int _forced_traitors = -1, bool _remove_extra_suspects = false)
		: base(new Vector2Int(4, 4), _difficulty_01, _forced_address_size, _forced_innocents, _forced_meddlers, _forced_underlings, _forced_traitors, _remove_extra_suspects)
	{
		hours_passed = 0;
		reputation_manager = new CaseReputationManager(_reputation, base.callReputationRoleFunction, base.callRoleOnReputationChangeCallback);
		createBoardAndStart(new List<Roles>(), _forced_roles, _case_quirks);
	}

	public override CaseActionPayload getPayload()
	{
		return new ClockCaseActionPayload(reputation, hours_passed);
	}

	private void updateTimePass(List<RoleData> _ordered_roles)
	{
		foreach (LocationData item in orderedLocations((LocationData _l) => _l is IAmClockLocation))
		{
			board = (item as IAmClockLocation).onTimePassed(this, board, hours_passed);
		}
		callRoleFunctionCheckOverride(_ordered_roles, (IAmClockRole _c, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _b) => _c.onTimePassed(_b, reputation, hours_passed));
		foreach (CaseQuirkData item2 in orderedQuirks((CaseQuirkData _q) => _q.is_time_quirk))
		{
			item2.onTime(this, hours_passed, random);
		}
	}

	public void roleChangeDuringTimePass(List<int> _address)
	{
		override_role_occured.addRange(_address);
	}

	public CaseSnapshot waitTime(int _hours_waited = 1)
	{
		hours_passed += _hours_waited;
		updateTimePass(board.getOrderdRolesForEventCalls());
		return snapshot();
	}

	public int getTrueHoursPassed()
	{
		return hours_passed;
	}

	protected override void onInvestigate(int _address, List<RoleData> _ordered_roles_for_event_calls)
	{
		hours_passed += 2;
		updateTimePass(_ordered_roles_for_event_calls);
	}

	protected override void onArrest(RoleData _arrested_role, List<RoleData> _ordered_roles_for_event_calls)
	{
		hours_passed++;
		reputation_manager.onArrest(board, _arrested_role, _ordered_roles_for_event_calls);
		updateTimePass(_ordered_roles_for_event_calls);
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

	protected override CaseSnapshot generateCaseSnapshot(bool _silent = false)
	{
		return new ClockCaseSnapshot(getPayload() as ClockCaseActionPayload, base.case_solved, _silent ? classification_ratio : public_classification_ratio, _silent ? suspect_list : visual_suspect_list, suspect_list, board, hours_passed, reputation_status, reputation_manager);
	}

	protected override void checkForAchievements(bool _won)
	{
		base.checkForAchievements(_won);
		if (_won && hours_passed > 36)
		{
			SteamHelper.tryAchieve(Achiements.NO_OVERTIME_PAY);
		}
	}

	protected override CaseStats setRegionStats()
	{
		return new OfficeCaseStats
		{
			time_passed = hours_passed
		};
	}

	protected override string getUniqueSaveData()
	{
		return string.Format("{0},{1},{2}", reputation, hours_passed, reputation_manager.hidden_reputation ? "t" : "f");
	}

	public void setReputationFromLevelEditor(LevelEditorManager _manager, int _rep)
	{
		reputation_manager.setReputationFromLevelEditor(_manager, _rep);
	}

	public void setReputationFromCBCLead(CaseToCaseLead _lead, int _rep)
	{
		reputation_manager.setReputationFromCBCLead(_lead, _rep);
	}
}
