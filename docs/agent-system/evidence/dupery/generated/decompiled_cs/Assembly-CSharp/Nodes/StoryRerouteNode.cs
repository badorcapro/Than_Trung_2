using GRGLib.Maybe;
using UnityEngine;

namespace Nodes;

public class StoryRerouteNode : StoryNodeBase
{
	[SerializeField]
	private int reroute_target;

	public override void progressImmidiate(IStoryGraphNavigator _navigator)
	{
	}

	public override void progress(IStoryGraphNavigator _navigator)
	{
		progressNextAction(_navigator);
	}

	protected override Maybe<StoryNodeBase> getNextNode(IStoryGraphNavigator _navigator)
	{
		return getNextNode();
	}

	private Maybe<StoryNodeBase> getNextNode()
	{
		if ((graph as StoryNodeGraph).fetchNode(reroute_target) is StoryNodeBase obj)
		{
			return obj.maybe();
		}
		Debug.LogError($"Node with UID {reroute_target} is not a story node!!!");
		return new Maybe<StoryNodeBase>();
	}
}
