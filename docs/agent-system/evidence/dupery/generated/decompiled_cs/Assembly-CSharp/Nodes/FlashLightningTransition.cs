using System.Collections;
using TransitionScene;
using UnityEngine;

namespace Nodes;

public class FlashLightningTransition : StoryEventNodeBase
{
	public override IEnumerator eventCoroutine(IEventsRunner _controller)
	{
		return base.eventCoroutine(_controller);
	}

	public override void immidiateEvent(IEventsRunner _controller)
	{
		if (!(_controller is StoryEventRunner))
		{
			Debug.LogError("Cannot flash Lightning when not in the Transition scene");
		}
	}
}
