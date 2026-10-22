using GRGLib.Maybe;
using XNode;

namespace Nodes;

public class StoryStartNode : StoryNodeBase
{
	[Output(ShowBackingValue.Never, ConnectionType.Override, TypeConstraint.None, false)]
	public StoryNodeBase exit;

	public override void progress(IStoryGraphNavigator _navigator)
	{
		progressNextAction(_navigator);
	}

	public override void progressImmidiate(IStoryGraphNavigator _navigator)
	{
		getListInputValues<StoryEventNodeBase>("startEvents").ForEach(delegate(StoryEventNodeBase _e)
		{
			_e.immidiateEvent(_navigator.events_runner);
		});
	}

	public override Maybe<StoryNodeBase> getPreviousNode()
	{
		return new Maybe<StoryNodeBase>();
	}
}
