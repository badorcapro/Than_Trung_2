using System;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Nodes;

[CreateAssetMenu(menuName = "NodeGraphs/Story Graph")]
public class StoryNodeGraph : NodeGraphBase
{
	[SerializeField]
	private string graph_id;

	public string localisation_graph_id
	{
		get
		{
			if (!(graph_id == ""))
			{
				return graph_id;
			}
			return base.name;
		}
	}

	public StoryStartNode fetchStartNode()
	{
		List<StoryStartNode> list = fetchNodes<StoryStartNode>();
		if (list.Count != 1)
		{
			throw new ArgumentException("There isnt 1 start node in this story graph! There can only be 1 and there must be 1!");
		}
		return list[0];
	}

	private void fakeRunTo(StoryNodeBase _node, IStoryGraphNavigator _navigator)
	{
		Debug.Log("Fake running!");
		_navigator.resetStory();
		List<StoryNodeBase> list = new List<StoryNodeBase>();
		Maybe<StoryNodeBase> previousNode = _node.getPreviousNode();
		while (previousNode.is_some)
		{
			list.Add(previousNode.value);
			previousNode = previousNode.value.getPreviousNode();
		}
		list.Reverse();
		for (int i = 0; i < list.Count; i++)
		{
			list[i].progressImmidiate(_navigator);
		}
		_node.progress(_navigator);
	}
}
