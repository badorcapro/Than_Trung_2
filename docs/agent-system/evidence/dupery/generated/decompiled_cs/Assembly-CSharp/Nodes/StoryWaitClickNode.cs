using XNode;

namespace Nodes;

public class StoryWaitClickNode : StoryNodeBase, INodeActionMarker
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase exit;

	public override void progress(IStoryGraphNavigator _navigator)
	{
		_navigator.waitForClick(delegate
		{
			progressNextAction(_navigator);
		});
	}

	public override void progressImmidiate(IStoryGraphNavigator _navigator)
	{
	}
}
