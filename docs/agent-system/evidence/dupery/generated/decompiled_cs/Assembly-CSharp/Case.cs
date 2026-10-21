using System;
using System.Collections.Generic;
using System.Linq;
using CaseCreation;
using GRGLib.Extensions.Collections;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using GameStats;
using Leads;
using LevelEditor;
using Nodes.Logic;
using Quirks;
using Save;
using UnityEngine;

public abstract class Case
{
	private bool has_investigated;

	protected Maybe<Lead> current_lead = new Maybe<Lead>();

	protected float difficulity_01;

	protected CaseRatioBuilderData ratio_builder_data;

	protected Dictionary<RoleClassifications, int> classification_ratio = new Dictionary<RoleClassifications, int>();

	protected Dictionary<RoleClassifications, int> public_classification_ratio = new Dictionary<RoleClassifications, int>();

	protected HashSet<RoleData> suspect_list = new HashSet<RoleData>();

	protected HashSet<RoleData> visual_suspect_list = new HashSet<RoleData>();

	protected Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> board = new Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>>();

	protected System.Random random;

	protected HashSet<int> override_role_occured = new HashSet<int>();

	public abstract CaseType case_type { get; }

	public bool began { get; protected set; }

	public Maybe<int> tutorial_level { get; protected set; } = new Maybe<int>();

	public bool case_solved { get; protected set; }

	public bool visual_suspect_list_changed { get; protected set; }

	public Vector2Int board_size { get; private set; }

	public List<CaseQuirks> quirk_markers { get; private set; } = new List<CaseQuirks>();

	public List<CaseQuirkData> active_quirks { get; private set; } = new List<CaseQuirkData>();

	public static Case copyCase(Case _case)
	{
		return _case.case_type switch
		{
			CaseType.CLOCK => new ClockCase(_case as ClockCase), 
			CaseType.CASINO => new CasinoCase(_case as CasinoCase), 
			CaseType.DOCKS => new DocksCase(_case as DocksCase), 
			_ => throw new ArgumentException($"No copyCase function set up for case type {_case.case_type}!"), 
		};
	}

	public List<Either<CaseQuirkData, Clue>> getQuirksAndClues()
	{
		if (!current_lead.is_some)
		{
			return active_quirks.Select((CaseQuirkData _q) => new Either<CaseQuirkData, Clue>(_q)).ToList();
		}
		List<Clue> clues = current_lead.value.clues;
		return active_quirks.Select((CaseQuirkData _q) => new Either<CaseQuirkData, Clue>(_q)).ToList().addRange(from _c in clues
			where !(_c is QuirkClue)
			select new Either<CaseQuirkData, Clue>(_c));
	}

	public bool hasMarkerQuirk(CaseQuirks _quirk)
	{
		return quirk_markers.Contains(_quirk);
	}

	public abstract CaseActionPayload getPayload();

	private Case(Vector2Int _board_size, float _diff, CaseRatioBuilderData _ratio_data)
	{
		board_size = _board_size;
		random = RandomExtensions.freshRandom();
		difficulity_01 = _diff;
		ratio_builder_data = _ratio_data;
	}

	protected Case(Lead _lead, float _diff, CaseRatioBuilderData _ratio_data)
	{
		board_size = _lead.current_board_size;
		random = RandomExtensions.freshRandom();
		difficulity_01 = _diff;
		ratio_builder_data = _ratio_data;
		current_lead = _lead.maybe();
	}

	private Case(Vector2Int _board_size, List<Roles> _suspect_list, Maybe<int> _tutorial, List<CaseQuirks> _case_quirks)
	{
		tutorial_level = _tutorial;
		board_size = _board_size;
		random = RandomExtensions.freshRandom();
		began = false;
		case_solved = false;
		difficulity_01 = 0f;
		suspect_list = _suspect_list.Select((Roles _r) => _r.createEmptyRole()).toHashSet();
		active_quirks = _case_quirks.Select((CaseQuirks _q) => _q.createQuirk()).ToList();
		quirk_markers = (from _q in orderedQuirks((CaseQuirkData _q) => _q.is_marker_quirk)
			select _q.quirk_type).toListSafe();
	}

	protected Case(LevelEditorManager _manager, Vector2Int _board_size)
	{
		tutorial_level = new Maybe<int>();
		board_size = _board_size;
		random = RandomExtensions.freshRandom();
		began = false;
		case_solved = false;
		difficulity_01 = 0f;
		classification_ratio = CaseHelper.getEmptyRatio();
		board = CaseHelper.getEmptyBoard(_board_size);
		suspect_list = new HashSet<RoleData>();
		active_quirks = new List<CaseQuirkData>();
		quirk_markers = new List<CaseQuirks>();
	}

	protected Case(Case _editor_case)
	{
		tutorial_level = new Maybe<int>();
		board_size = _editor_case.board_size;
		random = RandomExtensions.freshRandom();
		began = false;
		case_solved = false;
		difficulity_01 = 0f;
		suspect_list = _editor_case.suspect_list.copy();
		active_quirks = _editor_case.active_quirks.copy();
		quirk_markers = _editor_case.quirk_markers.copy();
		CaseSnapshot caseSnapshot = _editor_case.pregameSnap();
		board = CaseHelper.getEmptyBoard(board_size);
		foreach (KeyValuePair<Vector2Int, Maybe<Either<RoleData, LocationData>>> item in caseSnapshot.board)
		{
			if (!item.Value.is_some)
			{
				continue;
			}
			if (item.Value.value.is_a)
			{
				board[item.Key] = item.Value.value.maybe_a.value.toSave().fromSave(random).toEitherA<RoleData, LocationData>()
					.maybe();
				if (board[item.Key].value.maybe_a.value.getDisguise().is_some)
				{
					board[item.Key].value.maybe_a.value.setForcedDisguised();
				}
			}
			else if (item.Value.value.is_b)
			{
				board[item.Key] = item.Value.value.maybe_b.value.toSave().fromSave(random).toEitherB<RoleData, LocationData>()
					.maybe();
			}
		}
		classification_ratio = board.getOnBoardRatio(_true_class: true);
		public_classification_ratio = classification_ratio;
	}

	public Case(CaseBuildData _case_data)
		: this(_case_data.board_size, _case_data.difficulty_01, _case_data.ratio_builder_data)
	{
	}

	public Case(Vector2Int _board_size, float _difficulty_01, int _forced_address_size = -1, int _forced_innocents = -1, int _forced_meddlers = -1, int _forced_underlings = -1, int _forced_traitors = -1, bool _remove_extra_suspects = false)
		: this(_board_size, _difficulty_01, new CaseRatioBuilderData(_forced_address_size, _forced_innocents, _forced_meddlers, _forced_underlings, _forced_traitors))
	{
	}

	public Case(CaseSave _save, Maybe<Lead> _current_lead)
	{
		Case @case = this;
		tutorial_level = (_save.tutorial_level.is_some ? _save.tutorial_level.value.maybe() : new Maybe<int>());
		if (tutorial_level.is_some)
		{
			GameHandler.State.tutorial_case = (_save.case_type, tutorial_level.value).maybe();
		}
		current_lead = _current_lead;
		random = RandomExtensions.freshRandom();
		board_size = _save.board_size;
		began = _save.began;
		difficulity_01 = _save.difficulty_01;
		case_solved = _save.case_solved;
		classification_ratio = _save.classification_ratio.toDictionary();
		public_classification_ratio = _save.public_classification_ratio.toDictionary();
		active_quirks = _save.active_case_quirks.Select((CaseQuirks _q) => _q.createQuirk(_save.completed_quirks.Contains(_q))).ToList();
		quirk_markers = (from _q in orderedQuirks((CaseQuirkData _q) => _q.is_marker_quirk)
			select _q.quirk_type).toListSafe();
		suspect_list = _save.suspect_list.Select((Roles _r) => _r.createRole(-1, new Vector2Int(-1, -1), @case.random, new Maybe<RoleData>())).toHashSet();
		board = CaseHelper.getEmptyBoard(board_size);
		for (int i = 0; i < _save.board_roles.Count; i++)
		{
			RoleSave roleSave = _save.board_roles[i];
			RoleData roleData = roleSave.fromSave(random);
			roleData.setCaseRef(this);
			board[roleSave.info.board_position] = new Either<RoleData, LocationData>(roleData).maybe();
		}
		foreach (LocationDataSave board_location in _save.board_locations)
		{
			LocationData locationData = board_location.fromSave(random);
			if (_save.location_disguises.ContainsKey(locationData.location_type))
			{
				locationData.setDisguiseFromSave(_save.location_disguises[locationData.location_type]);
			}
			board[new Vector2Int(board_location.board_position.Item1, board_location.board_position.Item2)] = new Either<RoleData, LocationData>(locationData).maybe();
		}
		if (_save.visual_suspect_list.is_some)
		{
			visual_suspect_list = _save.visual_suspect_list.value.Select((Roles _r) => _r.createRole(-1, new Vector2Int(-1, -1), @case.random, new Maybe<RoleData>())).toHashSet();
			visual_suspect_list_changed = true;
		}
		else
		{
			createVisualSuspectList(_check_board: true);
			visual_suspect_list_changed = false;
		}
		has_investigated = true;
	}

	protected void onCaseLoadEnd()
	{
		callRoleFunction(board.getOrderdRolesForEventCalls(), (ISpecialLoad _sl, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _b) => _sl.onCaseLoaded(_b));
		active_quirks.ForEach(delegate(CaseQuirkData _q)
		{
			_q.onCaseLoaded(this, board, random);
		});
	}

	public Case(Vector2Int _board_size, List<Roles> _suspect_list, List<RoleData> _board_roles, List<LocationData> _board_locations, Maybe<int> _tutorial, Dictionary<RoleClassifications, int> _forced_ratio)
		: this(_board_size, _suspect_list, _tutorial, new List<CaseQuirks>())
	{
		classification_ratio = _forced_ratio;
		public_classification_ratio = classification_ratio;
		board = CaseHelper.getEmptyBoard(board_size);
		foreach (RoleData _board_role in _board_roles)
		{
			board[_board_role.getBoardPosition()] = _board_role.toEitherA<RoleData, LocationData>().maybe();
		}
		foreach (LocationData _board_location in _board_locations)
		{
			board[_board_location.getBoardPosition()] = _board_location.toEitherB<RoleData, LocationData>().maybe();
		}
	}

	public Case(Vector2Int _board_size, List<Roles> _suspect_list, List<RoleData> _board_roles, List<LocationData> _board_locations, Maybe<int> _tutorial, List<CaseQuirks> _case_quirks = null)
		: this(_board_size, _suspect_list, _tutorial, (_case_quirks == null) ? new List<CaseQuirks>() : _case_quirks)
	{
		classification_ratio = new Dictionary<RoleClassifications, int>
		{
			{
				RoleClassifications.INNOCENT,
				0
			},
			{
				RoleClassifications.MEDDLER,
				0
			},
			{
				RoleClassifications.UNDERLING,
				0
			},
			{
				RoleClassifications.TRAITOR,
				0
			}
		};
		board = CaseHelper.getEmptyBoard(board_size);
		foreach (RoleData _board_role in _board_roles)
		{
			board[_board_role.getBoardPosition()] = _board_role.toEitherA<RoleData, LocationData>().maybe();
			classification_ratio[_board_role.role.getClassificationFromRoleType()]++;
		}
		public_classification_ratio = classification_ratio;
		foreach (LocationData _board_location in _board_locations)
		{
			board[_board_location.getBoardPosition()] = _board_location.toEitherB<RoleData, LocationData>().maybe();
		}
	}

	protected void createBoardAndStart(List<Roles> _available_roles, List<CaseQuirks> _quirks)
	{
		createBoardAndStart(_available_roles, new List<Roles>(), _quirks);
	}

	protected void createBoardAndStart(List<Roles> _available_roles, List<Roles> _forced, List<CaseQuirks> _quirks)
	{
		List<Clue> list = _quirks.Aggregate(new List<Clue>(), (List<Clue> _a, CaseQuirks _q) => _a.add(new QuirkClue(_immutable: false, _q)));
		list.AddRange(_forced.Aggregate(new List<Clue>(), (List<Clue> _a, Roles _fr) => _a.add(new RoleClue(_immutable: false, _fr, ClueTypes.ROLE_SUSPECTED))));
		suspect_list = populateBoard(createBoardFactory(difficulity_01, _available_roles, list, new RoleSetInfoStruct("", "", new List<Roles>(), RoleSetsGraph.SetsType.NONE), ratio_builder_data, random));
		createVisualSuspectList();
		onRoundStart();
	}

	protected void createBoardAndStart(Lead _lead, CaseRatioBuilderData _ratio_builder)
	{
		suspect_list = populateBoard(createBoardFactory(_lead, _ratio_builder, random));
		createVisualSuspectList();
		onRoundStart();
	}

	protected void startFromPresetBoard()
	{
		createVisualSuspectList();
		(from _e in board.getOrderdRolesForEventCalls()
			select _e.getBoardPosition()).ToList().ForEach(delegate(Vector2Int _r)
		{
			board[_r].value.maybe_a.value.onRoundCreated(this);
		});
		onRoundStart();
	}

	protected void createVisualSuspectList(bool _check_board = false)
	{
		List<CaseQuirkData> list = orderedQuirks((CaseQuirkData _q) => _q.is_visual_suspect_list_quirk);
		if (list.Count > 0)
		{
			visual_suspect_list = suspect_list.copy();
			visual_suspect_list_changed = true;
			_check_board = true;
			foreach (CaseQuirkData item in list)
			{
				visual_suspect_list = item.onVisualSuspectListCreation(visual_suspect_list, suspect_list, random);
			}
		}
		else
		{
			visual_suspect_list = suspect_list;
			visual_suspect_list_changed = false;
		}
		if (!_check_board)
		{
			return;
		}
		foreach (KeyValuePair<Vector2Int, Maybe<Either<RoleData, LocationData>>> item2 in board)
		{
			if (item2.Value.is_some && item2.Value.value.is_a)
			{
				RoleData value = item2.Value.value.maybe_a.value;
				if (value.getIsArrested())
				{
					checkAddSuspect(value.reveal_as);
				}
				else if (value.getIsInvestigated() && !value.getIsObscured())
				{
					checkAddSuspect(value.getVisualRole().role);
				}
			}
		}
	}

	public virtual CaseSnapshot useLocationAbility(LocationTypes _location, List<AbilityData> _data)
	{
		Dictionary<LocationTypes, LocationData> locationsInPlay = board.getLocationsInPlay();
		if (!locationsInPlay.ContainsKey(_location))
		{
			Debug.LogError($"Trying to use ability of a not in play location! {_location}!");
			return snapshot();
		}
		locationsInPlay[_location].useAbility(this, board, getPayload(), _data);
		return snapshot();
	}

	public virtual CaseSnapshot useSpecialAbility(int _ability_user_address, List<AbilityData> _data)
	{
		List<RoleData> orderdRolesForEventCalls = board.getOrderdRolesForEventCalls();
		_data = orderdRolesForEventCalls.Aggregate(_data, (List<AbilityData> _a, RoleData _r) => (!(_r is IChangeAbilityTargets changeAbilityTargets)) ? _a : changeAbilityTargets.changeAbilityData(this, board, _a, _ability_user_address));
		for (int i = 0; i < orderdRolesForEventCalls.Count; i++)
		{
			board = orderdRolesForEventCalls[i].onSpecialAbilityUsed(board, getPayload(), _ability_user_address, _data);
		}
		SteamHelper.addToStats(AchiementStats.ABILITIES, 1);
		if (SteamHelper.shouldCheckFor(Achiements.ONE_FOR_THE_TEAM) && board.getRolesInPlay()[_ability_user_address].getIsDead())
		{
			SteamHelper.tryAchieve(Achiements.ONE_FOR_THE_TEAM);
		}
		return snapshot();
	}

	public virtual CaseSnapshot useAbility(int _ability_user_address, List<int> _target_addresses)
	{
		List<RoleData> orderdRolesForEventCalls = board.getOrderdRolesForEventCalls();
		_target_addresses = orderdRolesForEventCalls.Aggregate(_target_addresses, (List<int> _a, RoleData _r) => (!(_r is IChangeAbilityTargets changeAbilityTargets)) ? _a : changeAbilityTargets.changeAbilityTargets(this, board, _a, _ability_user_address));
		for (int i = 0; i < orderdRolesForEventCalls.Count; i++)
		{
			board = orderdRolesForEventCalls[i].onAbilityUsed(board, getPayload(), _ability_user_address, _target_addresses);
		}
		SteamHelper.addToStats(AchiementStats.ABILITIES, 1);
		if (SteamHelper.shouldCheckFor(Achiements.ONE_FOR_THE_TEAM) && board.getRolesInPlay()[_ability_user_address].getIsDead())
		{
			SteamHelper.tryAchieve(Achiements.ONE_FOR_THE_TEAM);
		}
		return snapshot();
	}

	public virtual CaseSnapshot investigateAddress(int _address)
	{
		List<RoleData> orderdRolesForEventCalls = board.getOrderdRolesForEventCalls();
		for (int i = 0; i < orderdRolesForEventCalls.Count; i++)
		{
			board = orderdRolesForEventCalls[i].onInvestigation(board, getPayload(), _address);
		}
		foreach (CaseQuirkData item in orderedQuirks((CaseQuirkData _q) => _q.is_investigate_quirk))
		{
			item.onInvestigate(this, board, _address, random);
		}
		onInvestigate(_address, orderdRolesForEventCalls);
		RoleData roleData = board.getRolesInPlay()[_address];
		if (visual_suspect_list_changed && roleData.getIsInvestigated() && !roleData.getIsObscured())
		{
			checkAddSuspect(roleData.getVisualRole().role);
		}
		if (roleData.getIsInvestigated())
		{
			SteamHelper.addToStats(AchiementStats.INVESTIGATIONS, 1);
		}
		has_investigated = true;
		return snapshot();
	}

	protected virtual void onInvestigate(int _address, List<RoleData> _ordered_roles_for_event_calls)
	{
	}

	public virtual CaseSnapshot arrestAddress(int _address)
	{
		board.getRolesInPlay().Keys.OrderByDescending((int x) => x).First();
		List<RoleData> orderdRolesForEventCalls = board.getOrderdRolesForEventCalls();
		for (int i = 0; i < orderdRolesForEventCalls.Count; i++)
		{
			board = orderdRolesForEventCalls[i].onArrest(board, getPayload(), _address);
		}
		RoleData roleData = board.getRolesInPlay()[_address];
		foreach (CaseQuirkData item in orderedQuirks((CaseQuirkData _q) => _q.is_arrest_quirk))
		{
			item.onArrest(this, board, roleData, random);
		}
		onArrest(roleData, orderdRolesForEventCalls);
		if (visual_suspect_list_changed && roleData.getIsArrested())
		{
			checkAddSuspect(roleData.reveal_as);
		}
		if (roleData.getIsArrested())
		{
			SteamHelper.addToStats(AchiementStats.ARRESTS, 1);
		}
		return snapshot();
	}

	protected abstract void onArrest(RoleData _arrested_role, List<RoleData> _ordered_roles_for_event_calls);

	public CaseSnapshot killAddress(int _address, RoleData _killer)
	{
		return killAddress(_address, _killer.maybe());
	}

	public virtual CaseSnapshot killAddress(int _address, Maybe<RoleData> _killer)
	{
		List<RoleData> orderdRolesForEventCalls = board.getOrderdRolesForEventCalls();
		RoleData roleData = orderdRolesForEventCalls.Find((RoleData _r) => _r.getAddress() == _address);
		if (roleData == null)
		{
			Debug.LogError($"Could not find any role to kill at the given address {_address}");
			return snapshot();
		}
		bool flag = !roleData.getIsDead();
		for (int i = 0; i < orderdRolesForEventCalls.Count; i++)
		{
			board = orderdRolesForEventCalls[i].onKill(board, getPayload(), _address, _killer);
		}
		foreach (CaseQuirkData item in orderedQuirks((CaseQuirkData _q) => _q.is_kill_quirk))
		{
			item.onKill(this, roleData, flag, random);
		}
		if (flag && roleData.getIsDead())
		{
			SteamHelper.addToStats(AchiementStats.DEATHS, 1);
		}
		return snapshot();
	}

	public virtual CaseSnapshot triggerLocation(LocationData _location)
	{
		foreach (RoleData orderdRolesForEventCall in board.getOrderdRolesForEventCalls())
		{
			orderdRolesForEventCall.onLocationTriggered(board, getPayload(), suspect_list.ToList(), _location);
		}
		return snapshot();
	}

	public virtual CaseSnapshot onCaseOver(bool _won)
	{
		List<RoleData> orderdRolesForEventCalls = board.getOrderdRolesForEventCalls();
		for (int i = 0; i < orderdRolesForEventCalls.Count; i++)
		{
			board = orderdRolesForEventCalls[i].onCaseOver(board, getPayload(), _won);
		}
		checkForAchievements(_won);
		return snapshot();
	}

	protected virtual void checkForAchievements(bool _won)
	{
		if (!_won)
		{
			return;
		}
		if (!has_investigated)
		{
			SteamHelper.tryAchieve(Achiements.DECISIVE_DETECTIVE);
		}
		if (!SteamHelper.shouldCheckFor(Achiements.GOOD_ENDING, Achiements.BAD_ENDING, Achiements.SELF_RELIANT))
		{
			return;
		}
		Dictionary<int, RoleData> rolesInPlay = board.getRolesInPlay();
		if (SteamHelper.shouldCheckFor(Achiements.GOOD_ENDING, Achiements.BAD_ENDING))
		{
			int num = rolesInPlay.Count((KeyValuePair<int, RoleData> _r) => _r.Value.getIsArrested() || _r.Value.getIsDead());
			if (num == 0)
			{
				SteamHelper.tryAchieve(Achiements.GOOD_ENDING);
			}
			if (num == rolesInPlay.Count)
			{
				SteamHelper.tryAchieve(Achiements.BAD_ENDING);
			}
		}
		if (SteamHelper.shouldCheckFor(Achiements.SELF_RELIANT) && rolesInPlay.Any((KeyValuePair<int, RoleData> _r) => _r.Value.getHasAnyAbility()) && rolesInPlay.All((KeyValuePair<int, RoleData> _r) => (!_r.Value.getHasAnyAbility() || !_r.Value.getIsAbilityExhausted()) && (!_r.Value.getVisualRole().getHasAnyAbility() || !_r.Value.getVisualRole().getIsAbilityExhausted())))
		{
			SteamHelper.tryAchieve(Achiements.SELF_RELIANT);
		}
	}

	public CaseStats getCaseStats()
	{
		CaseStats caseStats = setRegionStats();
		foreach (KeyValuePair<int, RoleData> item in board.getRolesInPlay())
		{
			if (item.Value.getIsInvestigated())
			{
				caseStats.investigated.increaseOrCreate(item.Value.role, 1);
			}
			if (item.Value.getIsArrested())
			{
				caseStats.arrested.increaseOrCreate(item.Value.role, 1);
				caseStats.arrested_align.increaseOrCreate(item.Value.getTrueAlignment(), 1);
			}
			if (item.Value.getIsDead())
			{
				caseStats.died.increaseOrCreate(item.Value.role, 1);
				caseStats.died_align.increaseOrCreate(item.Value.getTrueAlignment(), 1);
			}
			if (item.Value.getHasAnyAbility() && item.Value.getIsAbilityExhausted())
			{
				caseStats.ability_used.increaseOrCreate(item.Value.role, 1);
			}
			Maybe<RoleData> disguise = item.Value.getDisguise();
			if (disguise.is_some && disguise.value.getHasAnyAbility() && disguise.value.getIsAbilityExhausted())
			{
				caseStats.ability_used.increaseOrCreate(disguise.value.role, 1);
			}
		}
		return caseStats;
	}

	protected abstract CaseStats setRegionStats();

	protected CaseSnapshot snapshot()
	{
		case_solved = hasSolvedCase();
		return generateSnapshot();
	}

	protected CaseSnapshot silentSnapshot()
	{
		case_solved = hasSolvedCase();
		return generateSnapshot(_silent: true);
	}

	private CaseSnapshot generateSnapshot(bool _silent = false)
	{
		if (_silent)
		{
			return generateCaseSnapshot(_silent);
		}
		CaseSnapshot caseSnapshot = generateCaseSnapshot(_silent);
		foreach (CaseQuirkData item in orderedQuirks((CaseQuirkData _q) => _q.is_snapshot_quirk))
		{
			caseSnapshot = item.onSnapshot(this, caseSnapshot, random);
		}
		return caseSnapshot;
	}

	protected abstract CaseSnapshot generateCaseSnapshot(bool _silent = false);

	public bool checkForSolvedCase()
	{
		if (!case_solved)
		{
			return hasSolvedCase();
		}
		return true;
	}

	protected bool hasSolvedCase()
	{
		return (from _kv in board.getRolesInPlay()
			select _kv.Value into _r
			where _r.getTrueAlignment() == Alignments.EVIL
			select _r).All((RoleData _e) => _e.getIsArrested() || _e.getIsDead());
	}

	public CaseSnapshot begin()
	{
		if (began)
		{
			throw new Exception("Case has already began!");
		}
		began = true;
		return snapshot();
	}

	public CaseSnapshot beginFromSave()
	{
		if (began)
		{
			return snapshot();
		}
		return begin();
	}

	protected HashSet<RoleData> populateBoard(LeadBoardFactory _factory)
	{
		board = _factory.board;
		classification_ratio = _factory.ratio;
		public_classification_ratio = _factory.visual_ratio;
		return _factory.suspect_list;
	}

	protected LeadBoardFactory createBoardFactory(Lead _lead, CaseRatioBuilderData _ratio_builder, System.Random _rng)
	{
		return createBoardFactory(_lead.case_difficulty, _lead.lead_roles, _lead.clues, _lead.prime_suspect_set, _ratio_builder, _rng);
	}

	protected virtual LeadBoardFactory createBoardFactory(float _diff, List<Roles> _available, List<Clue> _clues, RoleSetInfoStruct _prime, CaseRatioBuilderData _ratio_builder, System.Random _rng)
	{
		return new LeadBoardFactory(_diff, _available, _clues, _prime, this, _ratio_builder, _rng);
	}

	public Func<Func<CaseQuirkData, bool>, List<CaseQuirkData>> setQuirkDataAndOrder(List<CaseQuirkData> _active_quirks)
	{
		active_quirks = _active_quirks;
		quirk_markers = (from _q in orderedQuirks((CaseQuirkData _q) => _q.is_marker_quirk)
			select _q.quirk_type).ToList();
		return orderedQuirks;
	}

	protected void onRoundStart()
	{
		List<RoleData> orderdRolesForEventCalls = board.getOrderdRolesForEventCalls();
		List<LocationData> orderdLocationsForEventCalls = board.getOrderdLocationsForEventCalls();
		for (int i = 0; i < orderdLocationsForEventCalls.Count; i++)
		{
			board = orderdLocationsForEventCalls[i].onRoundAwake(board, getPayload(), suspect_list.ToList());
		}
		for (int j = 0; j < orderdRolesForEventCalls.Count; j++)
		{
			board = orderdRolesForEventCalls[j].onRoundStarted(board, getPayload(), suspect_list.ToList());
		}
		for (int k = 0; k < orderdLocationsForEventCalls.Count; k++)
		{
			board = orderdLocationsForEventCalls[k].onRoundStarted(board, getPayload(), suspect_list.ToList());
		}
	}

	public CaseSave toSave()
	{
		return new CaseSave(case_type, board_size, began, difficulity_01, case_solved, active_quirks, classification_ratio, public_classification_ratio, suspect_list, visual_suspect_list_changed ? visual_suspect_list.maybe() : new Maybe<HashSet<RoleData>>(), board, tutorial_level, getUniqueSaveData());
	}

	protected abstract string getUniqueSaveData();

	public CaseSnapshot pregameSnap()
	{
		if (began)
		{
			throw new ArgumentException("Getting a pregame snapshot after the case has began is not allowed!");
		}
		return silentSnapshot();
	}

	public CaseSnapshot solvedGameSnap()
	{
		if (!solvedSnapAllowed())
		{
			throw new ArgumentException("Getting a solved game snapshot before the case is solved is not allowed!");
		}
		return silentSnapshot();
	}

	protected virtual bool solvedSnapAllowed()
	{
		return case_solved;
	}

	public void checkAddSuspect(Roles _role)
	{
		if (visual_suspect_list_changed && !getVisualSuspectList().Contains(_role))
		{
			visual_suspect_list.Add(_role.createEmptyRole());
		}
	}

	public HashSet<Roles> getSuspectList()
	{
		return suspect_list.Select((RoleData _rd) => _rd.role).toHashSet();
	}

	public HashSet<Roles> getVisualSuspectList()
	{
		return visual_suspect_list.Select((RoleData _rd) => _rd.role).toHashSet();
	}

	public void removeFromVisualSuspectList(Func<Roles, bool> _remove_condition)
	{
		visual_suspect_list = visual_suspect_list.Where((RoleData _s) => !_remove_condition(_s.role)).toHashSet();
		visual_suspect_list_changed = true;
	}

	public HashSet<LocationTypes> getLocations()
	{
		return (from _bp in board
			where _bp.Value.is_some && !_bp.Value.value.is_a
			select _bp into _ld
			select _ld.Value.value.maybe_b.value.location_type).toHashSet();
	}

	protected void callRoleFunction<T>(List<RoleData> _ordered_roles, Func<T, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>>, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>>> _func)
	{
		for (int i = 0; i < _ordered_roles.Count; i++)
		{
			if (_ordered_roles[i] is T arg)
			{
				board = _func(arg, board);
			}
			else if (_ordered_roles[i].getIsDisguised() && _ordered_roles[i].getDisguise().value is T arg2)
			{
				board = _func(arg2, board);
			}
		}
	}

	protected void callRoleFunctionCheckOverride<T>(List<RoleData> _ordered_roles, Func<T, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>>, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>>> _func)
	{
		for (int i = 0; i < _ordered_roles.Count; i++)
		{
			if (override_role_occured.Count > 0 && override_role_occured.Contains(_ordered_roles[i].getAddress()))
			{
				RoleData roleData = board.getRolesInPlay()[_ordered_roles[i].getAddress()];
				if (roleData is T arg)
				{
					board = _func(arg, board);
				}
				else if (roleData.getIsDisguised() && roleData.getDisguise().value is T arg2)
				{
					board = _func(arg2, board);
				}
				override_role_occured.Remove(_ordered_roles[i].getAddress());
			}
			else if (_ordered_roles[i] is T arg3)
			{
				board = _func(arg3, board);
			}
			else if (_ordered_roles[i].getIsDisguised() && _ordered_roles[i].getDisguise().value is T arg4)
			{
				board = _func(arg4, board);
			}
		}
		override_role_occured.Clear();
	}

	protected int callReputationRoleFunction(int _starting)
	{
		return callReputationRoleFunction(_starting, board.getOrderdRolesForEventCalls());
	}

	protected int callReputationRoleFunction(int _starting, List<RoleData> _ordered_roles)
	{
		for (int i = 0; i < _ordered_roles.Count; i++)
		{
			if (_ordered_roles[i] is IChangeReputation changeReputation)
			{
				_starting = changeReputation.checkReputationChange(board, getPayload(), _starting);
			}
			else if (_ordered_roles[i].getIsDisguised() && _ordered_roles[i].getDisguise().value is IChangeReputation changeReputation2)
			{
				_starting = changeReputation2.checkReputationChange(board, getPayload(), _starting);
			}
		}
		return _starting;
	}

	protected void callRoleOnReputationChangeCallback(int _reputation)
	{
		callRoleFunction(board.getOrderdRolesForEventCalls(), (ICareAboutReputation _r, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _b) => _r.onReputationChange(_b, getPayload(), _reputation));
	}

	public CaseSnapshot DEBUGsilentSnapshot()
	{
		return silentSnapshot();
	}

	protected List<LocationData> orderedLocations(Func<LocationData, bool> _filter)
	{
		return board.getOrderdLocationsForEventCalls().Where(_filter).ToList();
	}

	protected List<CaseQuirkData> orderedQuirks(Func<CaseQuirkData, bool> _filter)
	{
		return (from _q in active_quirks.Where(_filter)
			orderby _q.execution_order
			select _q).ToList();
	}

	public void setBoardFromLevelEditor(LevelEditorManager _manager, Dictionary<Vector2Int, Maybe<Either<RoleData, LocationData>>> _board, Dictionary<RoleClassifications, int> _ratio_mod)
	{
		if (_manager == null)
		{
			return;
		}
		board = _board;
		Dictionary<int, RoleData> rolesInPlay = board.getRolesInPlay();
		classification_ratio = CaseHelper.getEmptyRatio();
		foreach (KeyValuePair<int, RoleData> item in rolesInPlay)
		{
			classification_ratio[item.Value.role.getClassificationFromRoleType()]++;
		}
		classification_ratio.increaseOrCreateRange(_ratio_mod);
		public_classification_ratio = classification_ratio.copy();
	}

	public void setSuspectListFromLevelEditor(LevelEditorManager _manager, List<Roles> _suspect_list)
	{
		if (!(_manager == null))
		{
			suspect_list = _suspect_list.Select((Roles _r) => _r.createEmptyRole()).toHashSet();
		}
	}
}
