using UnityEngine;
using XNode;

namespace Nodes;

public class StoryEventActionNode : StoryNodeBase, INodeActionMarker
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase exit;

	[SerializeField]
	[NodeEnum]
	private EventTrigger trigger;

	[Input(ShowBackingValue.Never, ConnectionType.Override, TypeConstraint.None, true)]
	public StoryEventNodeBase events;

	public override void progress(IStoryGraphNavigator _navigator)
	{
		_navigator.events_runner.doEvents(getListInputValues<StoryEventNodeBase>("events"), trigger, delegate
		{
			progressNextAction(_navigator);
		});
	}

	public override void progressImmidiate(IStoryGraphNavigator _navigator)
	{
		getListInputValues<StoryEventNodeBase>("events").ForEach(delegate(StoryEventNodeBase _e)
		{
			_e.immidiateEvent(_navigator.events_runner);
		});
	}
}
