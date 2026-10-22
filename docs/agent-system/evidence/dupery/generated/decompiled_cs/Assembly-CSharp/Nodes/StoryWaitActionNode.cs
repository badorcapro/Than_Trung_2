using GRGLib.Coroutines;
using Tutorial;
using UnityEngine;
using XNode;

namespace Nodes;

public class StoryWaitActionNode : StoryNodeBase, INodeActionMarker
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase exit;

	[SerializeField]
	private bool close_all_text_boxes = true;

	[SerializeField]
	private float duration = 1f;

	public override void progress(IStoryGraphNavigator _navigator)
	{
		if (close_all_text_boxes && _navigator is TutorialStoryGraphNavigator tutorialStoryGraphNavigator)
		{
			tutorialStoryGraphNavigator.handler.disableRaycastBlock();
		}
		duration.wait().addCallback(delegate
		{
			progressNextAction(_navigator);
		}).start(_navigator.events_runner.coroutine_mono);
	}

	public override void progressImmidiate(IStoryGraphNavigator _navigator)
	{
		progressNextAction(_navigator);
	}
}
