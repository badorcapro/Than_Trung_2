using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Generic;
using UnityEngine;
using XNode;

namespace Nodes;

public class WaitRandomEventNode : StoryEventNodeBase
{
	[SerializeField]
	private MinMaxFloat duration = new MinMaxFloat(0.5f, 1.5f);

	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryEventNodeBase callback_events;

	public override IEnumerator eventCoroutine(IEventsRunner _controller)
	{
		yield return duration.get(_controller.random).wait();
		getInputValues<StoryEventNodeBase>("callback_events").ForEach(delegate(StoryEventNodeBase _e)
		{
			_e.doEvent(_controller);
		});
	}

	public override void immidiateEvent(IEventsRunner _controller)
	{
		getInputValues<StoryEventNodeBase>("callback_events").ForEach(delegate(StoryEventNodeBase _e)
		{
			_e.doEvent(_controller);
		});
	}
}
