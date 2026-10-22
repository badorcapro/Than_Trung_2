using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;
using XNode;

namespace Nodes;

public class StoryGateNode : StoryNodeBase
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase enter;

	[Input(ShowBackingValue.Never, ConnectionType.Override, TypeConstraint.None, false)]
	public StoryPredicateNodeBase predicate;

	[Output(ShowBackingValue.Never, ConnectionType.Override, TypeConstraint.None, false)]
	public StoryNodeBase pass;

	[Output(ShowBackingValue.Never, ConnectionType.Override, TypeConstraint.None, false)]
	public StoryNodeBase fail;

	public bool testPredicate(IStoryGraphNavigator _navigator)
	{
		List<StoryPredicateNodeBase> inputValues = getInputValues<StoryPredicateNodeBase>("predicate");
		if (inputValues.Count != 1)
		{
			Debug.LogError($"Could not find predicate! There are {inputValues.Count} of them attached to this gate node!");
			return false;
		}
		return inputValues[0].predicateResult(_navigator);
	}

	public override void progress(IStoryGraphNavigator _navigator)
	{
		Maybe<StoryNodeBase> nextNodeFromOutput = getNextNodeFromOutput(_navigator, testPredicate(_navigator) ? "pass" : "fail");
		if (!nextNodeFromOutput.is_some)
		{
			Debug.LogError("Could not find valid exit node!");
		}
		else
		{
			nextNodeFromOutput.value.progress(_navigator);
		}
	}
}
