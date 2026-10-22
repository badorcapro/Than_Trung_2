using System.Collections.Generic;
using AlternateModes;
using GRGLib.Coroutines;
using GRGLib.Extensions;
using GRGLib.Maybe;
using Hover;
using Leads;
using Save;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

public class GameHandler : MonoBehaviour
{
	public const string main_menu_scene = "MainMenuScene";

	public const string intro_cutscene = "IntroCutscene";

	public const string transition_scene = "LevelTransitionScene";

	public const string lead_selection_scene = "LeadSelectionScene";

	public const string game_scene = "GameScene";

	public const string events_scene = "EventScene";

	public const string lead_stasis_scene = "StasisScene";

	public const string summary_scene = "SummaryScene";

	public const string lineup_scene = "LineupScene";

	public const string credits_scene = "CreditsScene";

	public const string level_editor_scene = "LevelEditorScene";

	public const string gamepad_controls_name = "Gamepad";

	public const string switch_controls_name = "SwitchGamepad";

	public const string discord_url = "https://discord.gg/6gD6UJCMbt";

	public const string qq_url = "https://qm.qq.com/q/holtUCsdNK";

	[SerializeField]
	private GameTextHandler m_text_handler;

	[SerializeField]
	public RegionsSO regions_data;

	[Header("References")]
	[SerializeField]
	private TransitionHandler transition_handler;

	private string last_control_scheme = "";

	private Maybe<GameState> m_state = new Maybe<GameState>();

	private UniversalInputHandler m_universal_input;

	private TextLinksHandler m_links_handler;

	private CoroutineRunner scene_mover;

	public static GameHandler instance { get; private set; }

	public Maybe<CaseBuildData> case_to_build { get; private set; } = new Maybe<CaseBuildData>();

	public Maybe<Regions> quick_case { get; private set; } = new Maybe<Regions>();

	public Maybe<int> tutorial_case { get; private set; } = new Maybe<int>();

	public bool is_credits_replay { get; private set; }

	public bool using_gamepad => most_recent_control_scheme.equalToAny("Gamepad", "SwitchGamepad");

	public string most_recent_control_scheme { get; private set; }

	public float previous_region_progress { get; set; }

	public bool previous_run_tier_up { get; private set; }

	public string current_scene { get; private set; }

	public bool is_first_scene { get; private set; } = true;

	public static GameState State
	{
		get
		{
			if (instance.m_state.is_some)
			{
				return instance.m_state.value;
			}
			instance.m_state = SaveHandler.instance.game_state;
			if (instance.m_state.is_some)
			{
				return instance.m_state.value;
			}
			instance.m_state = new GameState().maybe();
			return instance.m_state.value;
		}
	}

	public static GameStatsData StatsData => SaveHandler.instance.stats_data;

	public static GameMetaData MetaData => SaveHandler.instance.meta_data;

	public static GameTextHandler Text => instance.m_text_handler;

	public static UniversalInputHandler UniversalInput => instance.m_universal_input;

	public static TextLinksHandler Links => instance.m_links_handler;

	public Maybe<List<Lead>> last_lead_info { get; private set; } = new Maybe<List<Lead>>();

	public Maybe<Case> level_editor_case { get; private set; } = new Maybe<Case>();

	private void Awake()
	{
		if (instance != null && instance != this)
		{
			Object.Destroy(base.gameObject);
			return;
		}
		Object.DontDestroyOnLoad(base.gameObject);
		instance = this;
		onGameBoot();
		SceneManager.sceneLoaded += OnSceneLoaded;
	}

	public bool continueGame()
	{
		if (SaveHandler.instance.startGame())
		{
			m_state = SaveHandler.instance.game_state;
			if (State.current_lead.is_some)
			{
				SteamHandler.setStatusRichPresence(SteamHelper.fromRegion(State.current_lead.value.case_type.fromType()));
			}
			else if (State.current_region.equalToAny(Regions.DOCKS, Regions.OFFICE, Regions.CASINO, Regions.SYNDICATE))
			{
				SteamHandler.setStatusRichPresence(SteamHelper.fromRegion(State.current_region));
			}
			else
			{
				SteamHandler.setStatusRichPresence(RichPresenceStatus.GENERIC_CASE);
			}
			return true;
		}
		Debug.LogError("Failed to continue game. Could not load game.");
		return false;
	}

	public void startNewGame(Regions _region)
	{
		startNewGame(_region, new Maybe<CaseType>());
	}

	public void startNewGame(Regions _region, Maybe<CaseType> _tutorial)
	{
		SaveHandler.instance.createSaverIfNotSome();
		m_state = new GameState(_region, _tutorial).maybe();
		SteamHandler.setStatusRichPresence(SteamHelper.fromRegion(_region));
	}

	public void startCustomLead(Lead _lead, LeadProgressionManager _progression_manager)
	{
		SaveHandler.instance.createSaverIfNotSome();
		m_state = new GameState(_lead, _progression_manager).maybe();
		SteamHandler.setStatusRichPresence(SteamHelper.fromRegion(_lead.case_type.fromType()));
		if (_lead.clues.Count > 0)
		{
			moveToScene("EventScene");
		}
		else
		{
			moveToScene("StasisScene");
		}
	}

	public void startMode(AlternateModeData _mode, Lead _lead, Maybe<LeadProgressionManager> _manager)
	{
		SaveHandler.instance.createSaverIfNotSome();
		m_state = new GameState(_mode, _lead, _manager).maybe();
		SteamHandler.setStatusRichPresence(SteamHelper.fromRegion(_lead.case_type.fromType()));
		if (!_manager.is_some)
		{
			moveToScene("GameScene");
		}
		else if (_lead.clues.Count > 0)
		{
			moveToScene("EventScene");
		}
		else
		{
			moveToScene("StasisScene");
		}
	}

	public bool moveToSceneWhenPossible(string _scene_name, bool _save = false)
	{
		if (scene_mover.is_running)
		{
			return false;
		}
		scene_mover.run(transition_handler.waitForLoading(delegate
		{
			moveToScene(_scene_name, _save);
		}));
		return true;
	}

	public bool moveToScene(string _scene_name, bool _save = false)
	{
		if (transition_handler.is_loading)
		{
			return false;
		}
		current_scene = _scene_name;
		is_first_scene = false;
		TransitionHandler.instance.moveToScene(_scene_name);
		if (_save)
		{
			saveGame(_save_stats: true, _scene_name);
		}
		onNewScene(_scene_name);
		return true;
	}

	private void onGameBoot()
	{
		current_scene = SceneManager.GetActiveScene().name;
		scene_mover = new CoroutineRunner(this);
	}

	public void playCreditsFromMainMenu()
	{
		is_credits_replay = true;
		moveToSceneWhenPossible("CreditsScene");
	}

	private void onNewScene(string _scene)
	{
		last_control_scheme = most_recent_control_scheme;
		switch (_scene)
		{
		case "MainMenuScene":
			resetGameData();
			StatsData.resetPreviousRun();
			resetLevelEditorCase();
			previous_run_tier_up = false;
			is_credits_replay = false;
			quick_case = new Maybe<Regions>();
			SaveHandler.instance.saveMetaData();
			SteamHandler.setStatusRichPresence(RichPresenceStatus.MAINMENU);
			break;
		case "GameScene":
			State.run_stats.refreshTimer();
			is_credits_replay = false;
			break;
		case "EventScene":
			State.run_stats.refreshTimer();
			is_credits_replay = false;
			break;
		case "StasisScene":
			State.run_stats.refreshTimer();
			is_credits_replay = false;
			break;
		}
	}

	private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
	{
		if (last_control_scheme != null && !(last_control_scheme == ""))
		{
			PlayerInput playerInput = Object.FindObjectOfType<PlayerInput>();
			playerInput.SwitchCurrentControlScheme(last_control_scheme, playerInput.devices.ToArray());
			Debug.Log("Set control scheme to " + last_control_scheme + " [Scene Start]");
		}
	}

	private void resetGameData()
	{
		m_state = new Maybe<GameState>();
	}

	public void runLost()
	{
		if (State.alternate_mode.is_some)
		{
			State.alternate_mode.value.onModeCompleted(State, _success: false);
		}
		finishRun(_reset_game_data: false);
		Debug.Log("RUN LOST");
	}

	public void runLostExit()
	{
		resetGameData();
		moveToScene("SummaryScene");
	}

	public void abandonRun(bool _move_scene = true)
	{
		finishRun();
		if (_move_scene)
		{
			moveToScene("MainMenuScene");
		}
	}

	public void finishRunSuccess()
	{
		State.run_stats.run_won = true;
		if (State.alternate_mode.is_some)
		{
			State.alternate_mode.value.onModeCompleted(State, _success: true);
		}
		if (State.current_lead.is_some)
		{
			StatsData.addPrimeSuspects(State.current_lead.value.prime_suspect_set.set_roles);
		}
		finishRun();
	}

	private void finishRun(bool _reset_game_data = true)
	{
		State.run_stats.stopTimer();
		State.endCurrentLead();
		List<Lead> list = State.endRunGetLeads();
		if (list.Count > 0)
		{
			last_lead_info = list.maybe();
		}
		if (State.run_stats.lead_stats.Count > 0)
		{
			StatsData.addRun(State.run_stats);
			previous_run_tier_up = SaveHandler.instance.meta_data.onRunEnd(State.run_stats);
		}
		SaveHandler.instance.saveGameStats();
		SaveHandler.instance.saveMetaData();
		if (_reset_game_data)
		{
			resetGameData();
		}
		SaveHandler.instance.deleteSave();
	}

	public bool saveGame(bool _save_stats = false, string _moving_to_scene = "")
	{
		if (m_state.is_some && m_state.value.ignore_save)
		{
			return false;
		}
		bool flag = SaveHandler.instance.save(State, _save_stats, _moving_to_scene);
		transition_handler.saveGameIcon(flag);
		return flag;
	}

	public void setCaseBuildData(CaseBuildData _data)
	{
		case_to_build = _data.maybe();
	}

	public void resetCaseBuildData()
	{
		case_to_build = new Maybe<CaseBuildData>();
	}

	public void setControlScheme(string _scheme, bool _immidiate_effect = false)
	{
		most_recent_control_scheme = _scheme;
		CursorController.instance.setHidden(using_gamepad, _immidiate_effect);
	}

	public void setTutorialLevel(int _level)
	{
		tutorial_case = _level.maybe();
	}

	public void setUniversalInputHandlerReference(UniversalInputHandler _ref)
	{
		m_universal_input = _ref;
	}

	public void setLinksHandlerReference(TextLinksHandler _links_handler)
	{
		m_links_handler = _links_handler;
	}

	public void setLevelEditorCase(Case _editor_case, bool _move_to_game_scene = true)
	{
		level_editor_case = _editor_case.maybe();
		if (_move_to_game_scene)
		{
			moveToScene("GameScene");
		}
	}

	public void resetLevelEditorCase()
	{
		level_editor_case = new Maybe<Case>();
	}

	public void setQuickCase(Regions _region)
	{
		quick_case = _region.maybe();
	}

	public void resetQuickCase()
	{
		quick_case = new Maybe<Regions>();
	}
}
