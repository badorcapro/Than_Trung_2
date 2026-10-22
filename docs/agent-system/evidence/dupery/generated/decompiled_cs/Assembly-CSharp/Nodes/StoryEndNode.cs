using XNode;

namespace Nodes;

public class StoryEndNode : StoryNodeBase
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase enter;

	public override void progress(IStoryGraphNavigator _navigator)
	{
		_navigator.onStoryFinish();
	}
}
