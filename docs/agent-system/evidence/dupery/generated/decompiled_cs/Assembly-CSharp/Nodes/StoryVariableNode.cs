using UnityEngine;
using XNode;

namespace Nodes;

public class StoryVariableNode : StoryNodeBase, INodeActionMarker
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase exit;

	[SerializeField]
	private string key;

	[SerializeField]
	private string value = "true";

	public override void progress(IStoryGraphNavigator _navigator)
	{
		_navigator.setVariable(key, value);
	}
}
