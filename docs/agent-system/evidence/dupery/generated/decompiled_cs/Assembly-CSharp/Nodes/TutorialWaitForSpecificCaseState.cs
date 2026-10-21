using GRGLib.Maybe;
using Tutorial;
using UnityEngine;
using XNode;

namespace Nodes;

public class TutorialWaitForSpecificCaseState : StoryNodeBase, INodeActionMarker
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase enter;

	[SerializeField]
	[NodeEnum]
	private TutorialWaitForCaseState.CaseState state_1;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase exit;

	[SerializeField]
	[NodeEnum]
	private TutorialWaitForCaseState.CaseState state_2;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase exit_2;

	public override void progress(IStoryGraphNavigator _navigator)
	{
		if (_navigator is TutorialStoryGraphNavigator tutorialStoryGraphNavigator)
		{
			tutorialStoryGraphNavigator.waitForCaseState(checkState, delegate(CaseSnapshot _snap)
			{
				if (TutorialWaitForCaseState.checkState(state_1, _snap))
				{
					progressNextAction(_navigator);
				}
				else
				{
					Maybe<StoryNodeBase> nextNodeFromOutput = getNextNodeFromOutput(_navigator, "exit_2");
					if (nextNodeFromOutput.is_some)
					{
						nextNodeFromOutput.value.progress(_navigator);
					}
				}
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
		if (TutorialWaitForCaseState.checkState(state_1, _snap))
		{
			return true;
		}
		if (TutorialWaitForCaseState.checkState(state_2, _snap))
		{
			return true;
		}
		return false;
	}
}
