using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using AlternateModes;
using Audio;
using ControllerSupport;
using GRGLib.Extensions.Random;
using GRGLib.Maybe;
using GRGLib.Save.Json;
using Leads;
using Lineup;
using Save;
using Tutorial;
using UnityEngine;
using UnityEngine.InputSystem;
using Visual;

public class CaseHandler : MonoBehaviour
{
	[SerializeField]
	private RegionsSO regions_data;

	[Header("References")]
	[SerializeField]
	private GameVisualManager visual_world;

	[SerializeField]
	private RectTransform tutorial_handler_parent;

	[SerializeField]
	private RectTransform clue_obt_parent;

	[SerializeField]
	private PlayerInput player_input;

	[SerializeField]
	private CaseControllerSupportHandler controller_support;

	[Header("Prefabs")]
	[SerializeField]
	private TutorialHandler tutorial_handler_prefab;

	[SerializeField]
	private ClueObtainedMenu clue_obt_menu_prefab;

	private Case current_case;

	private CaseSnapshot last_snap;

	private bool moving_on;

	private Maybe<TutorialHandler> tutorial = new Maybe<TutorialHandler>();

	public CaseType case_type
	{
		get
		{
			if (current_case != null)
			{
				return current_case.case_type;
			}
			return CaseType.CLOCK;
		}
	}

	public bool in_tutorial
	{
		get
		{
			if (tutorial.is_some && tutorial.value.gameObject.activeSelf)
			{
				return tutorial.value.in_tutorial;
			}
			return false;
		}
	}

	public bool is_tutorial_level { get; private set; }

	public bool is_quick_case { get; private set; }

	private PureLogicCalls logic_calls => new PureLogicCalls(calculateInteraction, calculateAbility, calculateSpecialAbility, calculateLocationAbility, calculateItemAbility, calculateItemSwap, calculateBoatMovement, calculateFinishCase);

	private void Start()
	{
		AudioHandler.Atmo.stopAllAtmoAndStart(Atmo.RAIN_WINDOW);
		if (GameHandler.State.tutorial_case.is_some)
		{
			is_tutorial_level = true;
			startCase(TutorialHelper.createTutorialCase(GameHandler.State.tutorial_case.value.Item1, GameHandler.State.tutorial_case.value.Item2, RandomExtensions.freshRandom()));
			GameHandler.StatsData.addDiscoveredRolesAndLocations(current_case.getSuspectList(), current_case.getLocations());
			GameHandler.State.onCaseStart(current_case, new ClockCaseReward(0, 0, _syndicate_clue: false));
			Debug.Log("Starting case from tutorial");
			createAndSetUpTutorialHandler(current_case.case_type, GameHandler.State.tutorial_case.value.Item2);
		}
		else if (GameHandler.instance.level_editor_case.is_some)
		{
			Debug.Log("Starting case from level editor");
			startCase(Case.copyCase(GameHandler.instance.level_editor_case.value));
		}
		else if (GameHandler.State.current_case.is_some)
		{
			Debug.Log("Starting case from save");
			startCase(CaseSave.toCase(GameHandler.State.current_case.value, GameHandler.State.current_lead), _from_save: true);
			visual_world.setUpVisualSave();
			visual_world.checkCaseEnd(last_snap);
			if (current_case.tutorial_level.is_some)
			{
				GameHandler.instance.setTutorialLevel(current_case.tutorial_level.value);
			}
		}
		else if (GameHandler.State.current_lead.is_some)
		{
			Debug.Log("Starting case from Lead");
			startCase(GameHandler.State.current_lead.value.createCase(GameHandler.State));
			GameHandler.StatsData.addDiscoveredRolesAndLocations(current_case.getSuspectList(), current_case.getLocations());
			GameHandler.StatsData.addCaseQuirks(current_case.active_quirks);
			GameHandler.State.onCaseStart(current_case, GameHandler.State.current_lead.value.createCaseReward(GameHandler.State));
			GameHandler.instance.resetCaseBuildData();
		}
		else if (GameHandler.instance.quick_case.is_some)
		{
			Debug.Log("Starting quick case");
			is_quick_case = true;
			switch (GameHandler.instance.quick_case.value)
			{
			case Regions.OFFICE:
				startCase(new OfficeLeadProgressionManager(regions_data, GameHandler.MetaData.getTierOfRegion(Regions.OFFICE)).createQuickCase(RandomExtensions.freshRandom()));
				break;
			case Regions.CASINO:
				startCase(new CasinoLeadProgressionManager(regions_data, GameHandler.MetaData.getTierOfRegion(Regions.CASINO)).createQuickCase(RandomExtensions.freshRandom()));
				break;
			case Regions.DOCKS:
				startCase(new DocksLeadProgressionManager(regions_data, GameHandler.MetaData.getTierOfRegion(Regions.DOCKS)).createQuickCase(RandomExtensions.freshRandom()));
				break;
			default:
				Debug.LogError($"No quick case button set up for region {GameHandler.instance.quick_case.value}!");
				startCase(new OfficeLeadProgressionManager(regions_data, GameHandler.MetaData.getTierOfRegion(Regions.OFFICE)).createQuickCase(RandomExtensions.freshRandom()));
				break;
			}
			GameHandler.instance.resetQuickCase();
			GameHandler.StatsData.addDiscoveredRolesAndLocations(current_case.getSuspectList(), current_case.getLocations());
		}
		else if (GameHandler.instance.case_to_build.is_some)
		{
			Debug.Log("Starting case case to build");
			startCase(GameHandler.instance.case_to_build.value.buildCase());
			if (GameHandler.instance.case_to_build.value.quirk_added.is_some)
			{
				GameHandler.StatsData.addCaseQuirk(GameHandler.instance.case_to_build.value.quirk_added.value);
			}
			GameHandler.StatsData.addDiscoveredRolesAndLocations(current_case.getSuspectList(), current_case.getLocations());
			GameHandler.State.onCaseStart(current_case, GameHandler.instance.case_to_build.value.case_reward);
			GameHandler.instance.resetCaseBuildData();
		}
		else
		{
			Debug.LogError("No case to build or saved case was found! Not sure what to do :/");
		}
	}

	private void createAndSetUpTutorialHandler(CaseType _case_type, int _case)
	{
		TutorialHandler tutorialHandler = UnityEngine.Object.Instantiate(tutorial_handler_prefab, tutorial_handler_parent);
		tutorialHandler.setUp(visual_world.tutorial_references, player_input, controller_support.checkSelection);
		tutorialHandler.startTutorialLevel(_case_type, _case);
		tutorial = tutorialHandler.maybe();
	}

	public void forceTutorialSelect()
	{
		if (tutorial.is_some)
		{
			tutorial.value.forceSelect();
		}
	}

	public void checkForTutorialStateCheck(CaseSnapshot _snap)
	{
		if (tutorial.is_some)
		{
			tutorial.value.checkState(_snap);
		}
	}

	private void startCase(Case _case, bool _from_save = false)
	{
		current_case = _case;
		last_snap = (_from_save ? _case.beginFromSave() : _case.begin());
		visual_world.setUpWorld(_case, GameHandler.State.current_region, last_snap, is_tutorial_level, logic_calls, () => last_snap, onInteraction, delegate
		{
			onCaseSetUp(_from_save);
		});
		visual_world.setUpCaseReferences(_case);
		checkAltModeCaseStart();
		checkMusic();
	}

	private void checkMusic()
	{
		if (current_case.case_type == CaseType.DOCKS)
		{
			AudioHandler.Music.playMusicIfTime(new List<Music>
			{
				Music.DCK_A,
				Music.DCK_B
			}, RandomExtensions.freshRandom());
		}
		else if (current_case.case_type == CaseType.CASINO)
		{
			AudioHandler.Music.playMusicIfTime(new List<Music>
			{
				Music.CAS_A,
				Music.CAS_B
			}, RandomExtensions.freshRandom());
		}
		else
		{
			AudioHandler.Music.playMusicIfTime(new List<Music>
			{
				Music.A_MT,
				Music.B,
				Music.C,
				Music.D
			}, RandomExtensions.freshRandom());
		}
	}

	private void onCaseSetUp(bool _from_save = false)
	{
		if (!_from_save && !is_quick_case && !GameHandler.State.ignore_save)
		{
			GameHandler.State.current_case = current_case.toSave().maybe();
			GameHandler.instance.saveGame();
		}
	}

	private CaseSnapshot calculateInteraction(InteractionType _interaction, int _address)
	{
		last_snap = doInteraction(_interaction, _address);
		LogReports.Log($"{_interaction}: {_address}");
		return last_snap;
	}

	private CaseSnapshot calculateAbility(int _address, List<int> _targets)
	{
		last_snap = current_case.useAbility(_address, _targets);
		LogReports.Log($"Ability: {_address} ({_targets.toStringCommaSeperated()})");
		return last_snap;
	}

	private CaseSnapshot calculateSpecialAbility(int _address, List<AbilityData> _data)
	{
		last_snap = current_case.useSpecialAbility(_address, _data);
		LogReports.Log(string.Format("Spe Ability: {0} ({1})", _address, _data.Aggregate("", (string _a, AbilityData _d) => _a + _d.as_debug + ", ")));
		return last_snap;
	}

	private CaseSnapshot calculateLocationAbility(LocationData _location, List<AbilityData> _data)
	{
		last_snap = current_case.useLocationAbility(_location.location_type, _data);
		LogReports.Log(string.Format("Location Ability: {0} ({1})", _location.location_type, _data.Aggregate("", (string _a, AbilityData _d) => _a + _d.as_debug + ", ")));
		return last_snap;
	}

	private CaseSnapshot calculateItemAbility(Vector2Int _item_slot, List<AbilityData> _data)
	{
		if (!(current_case is BackAlleysCase backAlleysCase))
		{
			Debug.LogError("Trying to use Item in a none-BackAlley case! This is not allowed!");
			return last_snap;
		}
		last_snap = backAlleysCase.itemAbility(_item_slot, _data);
		return last_snap;
	}

	private CaseSnapshot calculateBoatMovement(Vector2Int _move_target)
	{
		if (!(current_case is DocksCase docksCase))
		{
			Debug.LogError("Trying to move boat in a none-docks case! This is not allowed!!!");
			return last_snap;
		}
		last_snap = docksCase.moveBoat(_move_target);
		LogReports.Log($"Boat Movement: ({_move_target.x}, {_move_target.y})");
		return last_snap;
	}

	private CaseSnapshot calculateItemSwap(Vector2Int _slot_1, Vector2Int _slot_2)
	{
		if (!(current_case is BackAlleysCase backAlleysCase))
		{
			Debug.LogError("Trying to use Item in a none-BackAlley case! This is not allowed!");
			return last_snap;
		}
		Debug.Log($"SWAPPING: {_slot_1.x}#{_slot_1.y} | {_slot_2.x}#{_slot_2.y}");
		last_snap = backAlleysCase.swapItems(_slot_1, _slot_2);
		return last_snap;
	}

	private CaseSnapshot calculateFinishCase()
	{
		if (!(current_case is DocksCase docksCase))
		{
			Debug.LogError("Trying to finish case in a none-docks case! This is not allowed!!!");
			return last_snap;
		}
		last_snap = docksCase.finishCase();
		LogReports.Log("Player \"Finish Case\"");
		return last_snap;
	}

	private void onInteraction()
	{
		if (!GameHandler.instance.level_editor_case.is_some && !is_quick_case)
		{
			checkAltModeInteraction();
			CaseState caseState = checkCaseOver();
			GameHandler.State.current_case = current_case.toSave().maybe();
			if (caseState == CaseState.MID_PLAY)
			{
				GameHandler.instance.saveGame();
			}
			else if (!is_tutorial_level && caseState == CaseState.LOST)
			{
				checkAltModeCaseEnd(_solved: false);
				GameHandler.instance.runLost();
			}
			else if (caseState == CaseState.WON)
			{
				checkAltModeCaseEnd(_solved: true);
				GameHandler.instance.saveGame();
				Debug.Log("CASE SOLVED!");
			}
			checkForTutorialStateCheck(last_snap);
		}
	}

	private void checkAltModeCaseStart()
	{
		if (GameHandler.State.alternate_mode.is_some && GameHandler.State.alternate_mode.value is IMessWithCases messWithCases)
		{
			messWithCases.onCaseStart(current_case, visual_world);
		}
	}

	private void checkAltModeInteraction()
	{
		if (GameHandler.State.alternate_mode.is_some && GameHandler.State.alternate_mode.value is IMessWithCases messWithCases)
		{
			messWithCases.onInteraction(current_case, visual_world);
		}
	}

	private void checkAltModeCaseEnd(bool _solved)
	{
		if (GameHandler.State.alternate_mode.is_some && GameHandler.State.alternate_mode.value is IMessWithCases messWithCases)
		{
			messWithCases.onCaseEnd(current_case, last_snap, _solved);
		}
	}

	private CaseSnapshot doInteraction(InteractionType _interaction, int _address)
	{
		return _interaction switch
		{
			InteractionType.INVESTIGATE => current_case.investigateAddress(_address), 
			InteractionType.ARREST => current_case.arrestAddress(_address), 
			InteractionType.ABILITY => current_case.useAbility(_address, new List<int>()), 
			InteractionType.KILL => current_case.killAddress(_address, new Maybe<RoleData>()), 
			_ => throw new ArgumentException($"No calculate interaction set up for interaction {_interaction}!"), 
		};
	}

	private CaseState checkCaseOver()
	{
		if (last_snap.case_over)
		{
			bool flag = false;
			if (last_snap.case_solved)
			{
				Dictionary<int, RoleData> rolesInPlay = last_snap.board.getRolesInPlay();
				flag = !rolesInPlay.Values.Any((RoleData _r) => (_r.getIsArrested() && _r.getTrueAlignment() == Alignments.GOOD) || (!_r.getIsArrested() && _r.getTrueAlignment() == Alignments.EVIL));
				if (flag)
				{
					SteamHelper.addToStats(AchiementStats.CASES_SOLVED_FLAWLESS, 1, _store_immidiate: false);
					if (SteamHelper.shouldCheckFor(Achiements.FLAWLESS_MIND) && rolesInPlay.Any((KeyValuePair<int, RoleData> _r) => _r.Value.role.getClassificationFromRoleType() == RoleClassifications.TRAITOR))
					{
						SteamHelper.tryAchieve(Achiements.FLAWLESS_MIND);
					}
				}
				SteamHelper.addToStats(AchiementStats.CASES_SOLVED, 1);
			}
			if (!GameHandler.State.current_lead.is_some)
			{
				if (!last_snap.case_solved)
				{
					return CaseState.LOST;
				}
				return CaseState.WON;
			}
			last_snap = current_case.onCaseOver(last_snap.case_solved);
			GameHandler.State.run_stats.onCaseEnd(current_case.getCaseStats(), current_case.case_type, last_snap.case_solved, flag);
			if (!last_snap.case_solved)
			{
				return CaseState.LOST;
			}
			return CaseState.WON;
		}
		return CaseState.MID_PLAY;
	}

	public void saveCase()
	{
		string text = Path.Combine(Application.dataPath, "../CasesSaved/");
		if (current_case.toSave().SaveDataToSetFolderAndNewFile("case_debug_save", ".json", text, _use_save_file: false))
		{
			Debug.Log("Printed json save into " + text + " folder");
		}
	}

	public void revealTruth()
	{
		visual_world.revealTruth();
	}

	public void caseSolveFinish()
	{
		if (moving_on)
		{
			return;
		}
		moving_on = true;
		if (is_quick_case)
		{
			GameHandler.instance.moveToSceneWhenPossible("MainMenuScene");
		}
		else if (GameHandler.instance.level_editor_case.is_some)
		{
			GameHandler.instance.moveToSceneWhenPossible("LevelEditorScene");
		}
		else if (GameHandler.State.tutorial_case.is_some)
		{
			if (GameHandler.State.onTutorialSolve())
			{
				GameHandler.instance.moveToSceneWhenPossible("GameScene");
			}
			else if (GameHandler.State.is_tutorial_replay)
			{
				GameHandler.instance.moveToSceneWhenPossible("MainMenuScene");
			}
			else
			{
				GameHandler.instance.moveToSceneWhenPossible("LevelTransitionScene");
			}
		}
		else if (!GameHandler.State.current_lead.is_some)
		{
			if (GameHandler.State.current_region == Regions.SYNDICATE)
			{
				checkSyndicateContinue();
			}
			else
			{
				Debug.LogError("Lead is not some and all other fallbacks have been exausted!");
			}
		}
		else if (GameHandler.State.alternate_mode.is_some && !GameHandler.State.custom_progression_manager.is_some)
		{
			GameHandler.instance.moveToSceneWhenPossible("GameScene");
		}
		else if (GameHandler.State.current_lead.value.is_lead_completed)
		{
			GameHandler.instance.finishRunSuccess();
			SteamHelper.tryAchieve(Achiements.COMPLETE_LEAD);
			GameHandler.instance.moveToSceneWhenPossible("SummaryScene");
		}
		else if (GameHandler.State.custom_progression_manager.is_some && GameHandler.State.custom_progression_manager.value.skip_event_scene)
		{
			GameHandler.instance.moveToSceneWhenPossible("StasisScene");
		}
		else
		{
			GameHandler.instance.moveToSceneWhenPossible("EventScene");
		}
	}

	private void checkSyndicateContinue()
	{
		if (GameHandler.State.lineup_clues.Count >= 3)
		{
			GameHandler.instance.moveToSceneWhenPossible("LineupScene");
		}
		else
		{
			GameHandler.instance.moveToSceneWhenPossible("LeadSelectionScene");
		}
	}

	public Maybe<ClueObtainedMenu> checkForSyndicateClue(bool _won)
	{
		if (!_won || is_quick_case || is_tutorial_level || !GameHandler.State.current_lead.is_some || GameHandler.instance.level_editor_case.is_some)
		{
			return new Maybe<ClueObtainedMenu>();
		}
		GameHandler.State.onCaseSolve(current_case);
		if (!GameHandler.State.current_lead.value.is_lead_completed || GameHandler.State.current_region != Regions.SYNDICATE)
		{
			return new Maybe<ClueObtainedMenu>();
		}
		Maybe<LineupClue> maybe = GameHandler.State.endCurrentLeadWithClue(RandomExtensions.freshRandom());
		if (maybe.is_some)
		{
			ClueObtainedMenu clueObtainedMenu = UnityEngine.Object.Instantiate(clue_obt_menu_prefab, clue_obt_parent);
			clueObtainedMenu.setUp(maybe.value);
			return clueObtainedMenu.maybe();
		}
		return new Maybe<ClueObtainedMenu>();
	}
}
