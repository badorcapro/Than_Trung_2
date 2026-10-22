using System.Collections;
using UnityEngine;
using XNode;

namespace Nodes;

public abstract class StoryEventNodeBase : NodeBase, INodeEventMarker
{
	[SerializeField]
	public int at_char = -1;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase exit;

	public string event_id => graph.name + "_" + UID;

	public virtual void doEvent(IEventsRunner _controller)
	{
		_controller.startEvent(this, eventCoroutine(_controller));
	}

	public virtual IEnumerator eventCoroutine(IEventsRunner _controller)
	{
		immidiateEvent(_controller);
		yield break;
	}

	public abstract void immidiateEvent(IEventsRunner _controller);
}
