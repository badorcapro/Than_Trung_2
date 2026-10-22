using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace Nodes;

public abstract class StoryNodeBase : NodeBase
{
	protected StoryNodeGraph story_graph => graph as StoryNodeGraph;

	public virtual void progressImmidiate(IStoryGraphNavigator _navigator)
	{
		progress(_navigator);
	}

	public abstract void progress(IStoryGraphNavigator _navigator);

	protected bool checkBranch(IStoryGraphNavigator _navigator)
	{
		return false;
	}

	protected virtual void progressNextAction(IStoryGraphNavigator _navigator)
	{
		if (!checkBranch(_navigator))
		{
			Maybe<StoryNodeBase> nextNode = getNextNode(_navigator);
			if (!nextNode.is_some)
			{
				_navigator.onStoryFinish();
			}
			else
			{
				nextNode.value.progress(_navigator);
			}
		}
	}

	protected virtual Maybe<StoryNodeBase> getNextNode(IStoryGraphNavigator _navigator)
	{
		return getNextNodeFromOutput(_navigator, "exit");
	}

	protected Maybe<StoryNodeBase> getNextNodeFromOutput(IStoryGraphNavigator _navigator, string _output_name)
	{
		List<StoryNodeBase> outputValues = getOutputValues<StoryNodeBase>(_output_name);
		if (outputValues.Count == 1)
		{
			return outputValues[0].maybe();
		}
		if (outputValues.Count > 0)
		{
			Debug.LogError("Output " + _output_name + " has multiple story node base! This is not allowed!");
			return outputValues[0].maybe();
		}
		return new Maybe<StoryNodeBase>();
	}

	public virtual Maybe<StoryNodeBase> getPreviousNode()
	{
		List<StoryNodeBase> inputValues = getInputValues<StoryNodeBase>("enter");
		if (inputValues.Count == 1)
		{
			return inputValues[0].maybe();
		}
		if (inputValues.Count > 0)
		{
			Debug.Log("As several inputs! Getting first previous node.");
			return inputValues[0].maybe();
		}
		return new Maybe<StoryNodeBase>();
	}
}
