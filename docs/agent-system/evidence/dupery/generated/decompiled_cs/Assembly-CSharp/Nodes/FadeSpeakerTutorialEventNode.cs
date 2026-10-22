using System.Collections;
using GRGLib.Coroutines;
using Tutorial;
using UnityEngine;

namespace Nodes;

public class FadeSpeakerTutorialEventNode : StoryEventNodeBase
{
	[SerializeField]
	private float target;

	[SerializeField]
	private float duration = 0.5f;

	public override void immidiateEvent(IEventsRunner _controller)
	{
		if (!(_controller is TutorialEventsRunner tutorialEventsRunner))
		{
			Debug.LogError("Trying to use a tutorial event node without a tutorial event runner!");
			return;
		}
		if (target < 1f)
		{
			tutorialEventsRunner.to_ignore.Add(DialogueSpeachers.NARRATOR);
		}
		else
		{
			tutorialEventsRunner.to_ignore.Remove(DialogueSpeachers.NARRATOR);
		}
		tutorialEventsRunner.tutorial_handler.getLieutenantImage().color = new Color(1f, 1f, 1f, target);
	}

	public override IEnumerator eventCoroutine(IEventsRunner _controller)
	{
		if (!(_controller is TutorialEventsRunner tutorialEventsRunner))
		{
			Debug.LogError("Trying to use a tutorial event node without a tutorial event runner!");
			yield break;
		}
		if (target < 1f)
		{
			tutorialEventsRunner.to_ignore.Add(DialogueSpeachers.NARRATOR);
		}
		else
		{
			tutorialEventsRunner.to_ignore.Remove(DialogueSpeachers.NARRATOR);
		}
		yield return tutorialEventsRunner.tutorial_handler.getLieutenantImage().fade(target, duration, CoroutineExtensions.easeInOutFunc);
	}
}
