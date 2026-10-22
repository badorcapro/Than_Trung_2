using System;
using System.Collections.Generic;
using Audio;
using Codex;
using ControllerSupport;
using Tutorial;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Visual;

public class GameVisualManager : MonoBehaviour
{
	[SerializeField]
	private RegionsVisualsDataSO region_visual_data;

	[Header("References")]
	[SerializeField]
	private CaseEndVisualManager case_end_manager;

	[SerializeField]
	private Canvas canvas;

	[SerializeField]
	private PlayerInput player_input;

	[SerializeField]
	private CodexMenu codex;

	[SerializeField]
	private CaseControllerSupportHandler controller_support_handler;

	[SerializeField]
	private AbilityVisualManager ability_manager;

	[SerializeField]
	private NoteToolsInputsCallback tools_notes_input;

	[Header("Settings")]
	[SerializeField]
	private RoleVisualDataSO visuals_data;

	private WorldVisualManager world_manager;

	public Func<InteractionType, int, CaseSnapshot> do_interaction;

	public Func<int, List<int>, CaseSnapshot> do_ability;

	public Func<int, List<AbilityData>, CaseSnapshot> do_special_ability;

	public Func<LocationData, List<AbilityData>, CaseSnapshot> do_location_ability;

	private Action on_interaction;

	private bool is_tutorial_level;

	public TutorialReferences tutorial_references => world_manager.getTutorialReferences();

	public CaseType case_type { get; private set; }

	public Regions region_type { get; private set; }

	public void setUpWorld(Case _case, Regions _region, CaseSnapshot _case_snapshot, bool _tutorial, PureLogicCalls _logic_calls, Func<CaseSnapshot> _get_snap, Action _on_interact, Action _setup_callback)
	{
		case_type = _case.case_type;
		region_type = _region;
		is_tutorial_level = _tutorial;
		do_interaction = _logic_calls.do_interaction;
		do_ability = _logic_calls.do_ability;
		do_special_ability = _logic_calls.do_special_ability;
		do_location_ability = _logic_calls.do_location_ability;
		on_interaction = _on_interact;
		world_manager = UnityEngine.Object.Instantiate(region_visual_data.getWorldManagerPrefab(_case.case_type), base.transform);
		world_manager.transform.SetAsFirstSibling();
		world_manager.setUp(canvas, player_input, controller_support_handler, ability_manager, codex, _case_snapshot, _case.board_size, visuals_data, _case.getQuirksAndClues(), doAction, doAbility, doSpecialAbility, doLocationAbility, _get_snap, _logic_calls, renewWorld, _setup_callback);
		world_manager.setUpNoteToolsCallback(tools_notes_input);
		case_end_manager.setUp(world_manager.transform as RectTransform, world_manager.end_menu_reopen_buttons);
	}

	public void setUpCaseReferences(Case _case)
	{
		world_manager.setUpCaseReferences(_case);
	}

	public void setUpVisualSave()
	{
		world_manager.setUpVisualSave();
	}

	public void checkCaseEnd(CaseSnapshot _snap)
	{
		if (_snap.case_solved)
		{
			case_end_manager.onCaseEnd(is_tutorial_level, _solved: true, _snap);
		}
		else if (_snap.case_lost)
		{
			case_end_manager.onCaseEnd(is_tutorial_level, _solved: false, _snap);
		}
	}

	private void doAction(InteractionType _action, int _address)
	{
		renewWorld(do_interaction(_action, _address));
	}

	private void doAbility(int _address, List<int> _targets)
	{
		renewWorld(do_ability(_address, _targets));
	}

	private void doSpecialAbility(int _address, List<AbilityData> _data)
	{
		renewWorld(do_special_ability(_address, _data));
	}

	private void doLocationAbility(LocationData _location, List<AbilityData> _data)
	{
		renewWorld(do_location_ability(_location, _data));
	}

	private void renewWorld(CaseSnapshot _snap)
	{
		AudioHandler.Sfx.Queuer.resetQueue();
		world_manager.renewWorld(_snap);
		AudioHandler.Sfx.Queuer.playAndEmptyQueue();
		checkCaseEnd(_snap);
		on_interaction();
	}

	public void revealTruth()
	{
		StartCoroutine(world_manager.revealTruth());
	}
}
