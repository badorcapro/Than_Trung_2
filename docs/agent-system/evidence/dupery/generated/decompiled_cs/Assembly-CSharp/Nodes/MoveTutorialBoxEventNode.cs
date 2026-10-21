using System.Collections;
using GRGLib.Coroutines;
using Tutorial;
using UnityEngine;

namespace Nodes;

public class MoveTutorialBoxEventNode : StoryEventNodeBase
{
	[SerializeField]
	private Vector2 target_position;

	[SerializeField]
	private float duration;

	public override IEnumerator eventCoroutine(IEventsRunner _controller)
	{
		if (_controller is TutorialEventsRunner tutorialEventsRunner)
		{
			yield return tutorialEventsRunner.tutorial_handler.getTextBoxTransform().anchoredMove(target_position, duration, CoroutineExtensions.easeInOutFunc);
		}
		else
		{
			Debug.LogError("Cannot move tutorial box without a tutorial events runner!");
		}
	}

	public override void immidiateEvent(IEventsRunner _controller)
	{
		if (_controller is TutorialEventsRunner tutorialEventsRunner)
		{
			tutorialEventsRunner.tutorial_handler.getTextBoxTransform().anchoredPosition = target_position;
		}
		else
		{
			Debug.LogError("Cannot move tutorial box without a tutorial events runner!");
		}
	}
}
