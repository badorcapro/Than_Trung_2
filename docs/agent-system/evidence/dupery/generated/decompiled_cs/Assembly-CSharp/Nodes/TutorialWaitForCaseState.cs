using System.Linq;
using Tutorial;
using UnityEngine;
using XNode;

namespace Nodes;

public class TutorialWaitForCaseState : StoryNodeBase, INodeActionMarker
{
	public enum CaseState
	{
		ALL_INVESTIGATED = 0,
		MISTAKE_MADE = 1,
		CASE_SOLVE = 2,
		TAILOR_INVESTIGATED = 3,
		ALL_TAILOR_INVESTIGATED = 4,
		SCOUNDREL_FAILED_ARREST_CLOCK = 5,
		ANY_ARRESTED = 101,
		BOAT_ON_DOCKS = 102
	}

	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase exit;

	[SerializeField]
	[NodeEnum]
	private CaseState state;

	public override void progress(IStoryGraphNavigator _navigator)
	{
		if (_navigator is TutorialStoryGraphNavigator tutorialStoryGraphNavigator)
		{
			tutorialStoryGraphNavigator.waitForCaseState(checkState, delegate
			{
				progressNextAction(_navigator);
			});
		}
		else
		{
			Debug.LogError("Cant wait for case state without a tutorial story graph navigator!!!");
			progressNextAction(_navigator);
		}
	}

	private bool checkState(CaseSnapshot _snap)
	{
		return checkState(state, _snap);
	}

	public static bool checkState(CaseState _state, CaseSnapshot _snap)
	{
		switch (_state)
		{
		case CaseState.ALL_INVESTIGATED:
			return !_snap.board.getRolesInPlay().Values.Any((RoleData _r) => !_r.getIsInvestigated());
		case CaseState.MISTAKE_MADE:
			return _snap.board.getRolesInPlay().Values.Any((RoleData _r) => _r.getIsArrested() && _r.getTrueAlignment() == Alignments.GOOD);
		case CaseState.CASE_SOLVE:
			return _snap.case_solved;
		case CaseState.TAILOR_INVESTIGATED:
			return _snap.board.getRolesInPlay().Values.Any((RoleData _r) => _r.getIsInvestigated() && _r.getVisualRole().role == Roles.TAILOR);
		case CaseState.ALL_TAILOR_INVESTIGATED:
			return !_snap.board.getRolesInPlay().Values.Any((RoleData _r) => !_r.getIsInvestigated() && _r.getVisualRole().role == Roles.TAILOR);
		case CaseState.SCOUNDREL_FAILED_ARREST_CLOCK:
			if (_snap is ClockCaseSnapshot clockCaseSnapshot)
			{
				return _snap.board.getRolesInPlay().Values.Aggregate(0, (int _a, RoleData _r) => _a + (_r.getIsInvestigated() ? 2 : 0) + (_r.getIsArrested() ? 1 : 0)) != clockCaseSnapshot.visual_hours_passed;
			}
			break;
		case CaseState.ANY_ARRESTED:
			return _snap.board.getRolesInPlay().Values.Any((RoleData _r) => _r.getIsArrested());
		case CaseState.BOAT_ON_DOCKS:
			if (_snap is DocksCaseSnapshot docksCaseSnapshot)
			{
				return docksCaseSnapshot.board.getLocationsInPlay()[LocationTypes.DOCKS].getBoardPosition() == docksCaseSnapshot.docks_payload.boat.position;
			}
			break;
		}
		Debug.LogError($"No check state set up for state {_state}!");
		return false;
	}
}
