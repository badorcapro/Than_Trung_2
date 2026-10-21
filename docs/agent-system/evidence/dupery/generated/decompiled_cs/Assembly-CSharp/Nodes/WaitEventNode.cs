using System.Collections;
using GRGLib.Coroutines;
using UnityEngine;
using XNode;

namespace Nodes;

public class WaitEventNode : StoryEventNodeBase
{
	[SerializeField]
	private float duration = 1f;

	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryEventNodeBase callback_events;

	public override IEnumerator eventCoroutine(IEventsRunner _controller)
	{
		yield return duration.wait();
		getInputValues<StoryEventNodeBase>("callback_events").ForEach(delegate(StoryEventNodeBase _e)
		{
			_e.doEvent(_controller);
		});
	}

	public override void immidiateEvent(IEventsRunner _controller)
	{
		getInputValues<StoryEventNodeBase>("callback_events").ForEach(delegate(StoryEventNodeBase _e)
		{
			_e.immidiateEvent(_controller);
		});
	}
}
