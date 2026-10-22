using System.Collections.Generic;
using Tutorial;
using UnityEngine;
using XNode;

namespace Nodes;

public class TutorialDrawOnBoardNode : StoryNodeBase, INodeActionMarker
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase exit;

	public List<Vector2> line_points;

	public override void progress(IStoryGraphNavigator _navigator)
	{
		if (_navigator is TutorialStoryGraphNavigator tutorialStoryGraphNavigator)
		{
			tutorialStoryGraphNavigator.tutorial_references.pen_manager.addFullyDrawnLine(line_points);
			progressNextAction(_navigator);
		}
		else
		{
			Debug.LogError("Cannot draw on board without a tutorial story graph navigator!");
			progressNextAction(_navigator);
		}
	}
}
