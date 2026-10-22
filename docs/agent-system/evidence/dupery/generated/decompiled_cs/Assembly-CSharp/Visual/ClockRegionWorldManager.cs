using System;
using System.Collections.Generic;
using ControllerSupport;
using Quirks;
using Tutorial;
using UnityEngine;
using UnityEngine.InputSystem;

namespace Visual;

public class ClockRegionWorldManager : WorldVisualManager
{
	[SerializeField]
	private TimeVisualManager time_manager;

	[SerializeField]
	private ReputationVisualManager reputation_manager;

	public override TutorialReferences getTutorialReferences()
	{
		return new TutorialReferences(suspect_list.transform as RectTransform, ratio_manager.transform as RectTransform, time_manager.transform as RectTransform, board_manager.transform as RectTransform, suspect_list.explanation_trans, reputation_manager.transform as RectTransform, pen_manager, rubber_manager, pins_controller);
	}

	protected override void setUpRegion(CaseSnapshot _case_snapshot, List<CaseQuirkData> _active_quirks, Func<CaseSnapshot> _get_snap, PureLogicCalls _logic_calls, Action<CaseSnapshot> _renew_world, PlayerInput _player_input, CaseControllerSupportHandler _controller_support, AbilityVisualManager _ab_manager)
	{
		renewRegionWorld(_case_snapshot);
	}

	protected override void renewRegionWorld(CaseSnapshot _snap)
	{
		if (!(_snap is ClockCaseSnapshot clockCaseSnapshot))
		{
			Debug.LogError("Snapshot is not a ClockCaseSnapshot! Clock Region Visuals Manager can only accept ClockCaseSnapshots!");
			return;
		}
		time_manager.progressTime(clockCaseSnapshot.visual_hours_passed);
		if (clockCaseSnapshot.reputation_hidden)
		{
			reputation_manager.hideReputation(clockCaseSnapshot.reputation_comment);
		}
		else if (reputation_manager.reputation_hidden)
		{
			reputation_manager.unhideReputation();
		}
		reputation_manager.setReputation(clockCaseSnapshot.clock_payload.reputation, clockCaseSnapshot.reputation_comment);
	}

	protected override void setUpRegionFromSave()
	{
	}
}
