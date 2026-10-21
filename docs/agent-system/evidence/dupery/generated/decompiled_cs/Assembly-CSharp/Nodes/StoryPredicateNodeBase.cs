using XNode;

namespace Nodes;

public abstract class StoryPredicateNodeBase : NodeBase, IPredicateNodeMarker
{
	[Output(ShowBackingValue.Never, ConnectionType.Override, TypeConstraint.None, false)]
	public StoryNodeBase exit;

	public abstract bool predicateResult(IStoryGraphNavigator _graph_navigator);
}
