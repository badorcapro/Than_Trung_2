using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using Codex;
using ControllerSupport;
using GRGLib.Coroutines;
using Leads;
using Quirks;
using Tutorial;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

namespace Visual;

public abstract class WorldVisualManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	protected BoardVisualManager board_manager;

	[SerializeField]
	protected SuspectListVisualManager suspect_list;

	[SerializeField]
	protected RatioVisualManager ratio_manager;

	[SerializeField]
	protected PenManager pen_manager;

	[SerializeField]
	protected RubberManager rubber_manager;

	[SerializeField]
	protected PinsController pins_controller;

	[SerializeField]
	protected StringManager string_manager;

	[SerializeField]
	protected ScissorsManager scissor_manager;

	[SerializeField]
	protected CaseQuirkListVisualManager quirks_visual_manager;

	[SerializeField]
	protected WorldAnimationEffectsVisualManager animation_effects_manager;

	[SerializeField]
	protected GameInstructionsManager instruction_manager;

	[SerializeField]
	protected BoardControllerSupportManager controller_support_manager;

	public List<Button> end_menu_reopen_buttons;

	protected RoleVisualDataSO visuals_data;

	public abstract TutorialReferences getTutorialReferences();

	public void setUp(Canvas _canvas, PlayerInput _player_input, CaseControllerSupportHandler _controller_handler, AbilityVisualManager _ab_manager, CodexMenu _codex, CaseSnapshot _case_snapshot, Vector2Int _board_size, RoleVisualDataSO _visuals_data, List<Either<CaseQuirkData, Clue>> _active_quirks, Action<InteractionType, int> _interact, Action<int, List<int>> _ability, Action<int, List<AbilityData>> _spe_ability, Action<LocationData, List<AbilityData>> _on_location_ability, Func<CaseSnapshot> _get_snap, PureLogicCalls _logic_calls, Action<CaseSnapshot> _renew_world, Action _set_up_callback)
	{
		visuals_data = _visuals_data;
		controller_support_manager.setControllerSupportReferences(_controller_handler);
		pins_controller.setUpReferences(_canvas);
		pen_manager.setUpReferences(_canvas, _player_input);
		rubber_manager.setUpReferences(_canvas, _player_input);
		string_manager.setUpReferences(_canvas, _player_input);
		scissor_manager.setUpReferences(_canvas, _player_input);
		instruction_manager.setUpReferences(_player_input);
		_ab_manager.setUpReferences(instruction_manager, board_manager, this, suspect_list);
		ratio_manager.setUp(_case_snapshot.classification_ratio);
		suspect_list.setUp(_controller_handler, _codex, _player_input, _case_snapshot, _case_snapshot.visual_suspect_list, _visuals_data, _get_snap);
		board_manager.setUp(_controller_handler, _ab_manager, _case_snapshot, _board_size, _visuals_data, _interact, _ability, _spe_ability, _on_location_ability, suspect_list.top_most_suspect, _set_up_callback);
		suspect_list.setUpSelectables(board_manager.right_most_slot);
		quirks_visual_manager.setUp(_codex, _active_quirks, board_manager.bottom_slots);
		controller_support_manager.setUp(board_manager);
		setUpRegion(_case_snapshot, (from _q in _active_quirks
			where _q.is_a
			select _q.maybe_a.value).ToList(), _get_snap, _logic_calls, _renew_world, _player_input, _controller_handler, _ab_manager);
		1f.wait(delegate
		{
			suspect_list.checkSnapshotForAnimations(_case_snapshot);
			animation_effects_manager.checkForWorldAnimations(_case_snapshot);
		}).start(this);
	}

	public virtual void setUpCaseReferences(Case _case)
	{
	}

	protected abstract void setUpRegion(CaseSnapshot _case_snapshot, List<CaseQuirkData> _active_quirks, Func<CaseSnapshot> _get_snap, PureLogicCalls _logic_calls, Action<CaseSnapshot> _renew_world, PlayerInput _player_input, CaseControllerSupportHandler _controller_handler, AbilityVisualManager _ab_manager);

	public void setUpNoteToolsCallback(NoteToolsInputsCallback _input)
	{
		_input.setUpToolReferences(pins_controller, pen_manager, string_manager, rubber_manager);
	}

	public void setUpVisualSave()
	{
		pen_manager.setUpSave();
		pins_controller.setUpFromSave();
		string_manager.setUpFromSave();
		pins_controller.resetRemappedIndeces();
		setUpRegionFromSave();
	}

	protected virtual void setUpRegionFromSave()
	{
	}

	public void renewWorld(CaseSnapshot _snap)
	{
		board_manager.renewBoard(_snap);
		suspect_list.checkSnapshotForAnimations(_snap);
		animation_effects_manager.checkForWorldAnimations(_snap);
		renewRegionWorld(_snap);
		bool case_over = _snap.case_over;
		if ((!case_over && suspect_list.checkAddSuspects(_snap.visual_suspect_list, visuals_data, board_manager.right_most_slot)) || (case_over && suspect_list.revealAllSuspects(_snap.true_suspect_list, visuals_data, board_manager.right_most_slot)))
		{
			board_manager.setBoardToSuspectNavigation(suspect_list.top_most_suspect);
		}
	}

	protected abstract void renewRegionWorld(CaseSnapshot _snap);

	public IEnumerator revealTruth()
	{
		if (SettingsHandler.reveal_all_clears_drawings)
		{
			pins_controller.clearAll();
			pen_manager.clearAll();
			string_manager.clearAll();
		}
		onRevealTruth();
		yield return board_manager.revealTruth();
	}

	protected virtual void onRevealTruth()
	{
	}
}
