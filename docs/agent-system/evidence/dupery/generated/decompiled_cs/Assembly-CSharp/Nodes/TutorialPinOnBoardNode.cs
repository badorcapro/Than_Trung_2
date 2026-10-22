using System.Collections.Generic;
using Tutorial;
using UnityEngine;
using XNode;

namespace Nodes;

public class TutorialPinOnBoardNode : StoryNodeBase, INodeActionMarker
{
	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase exit;

	public List<Vector2Int> pin_positions;

	public override void progress(IStoryGraphNavigator _navigator)
	{
		if (_navigator is TutorialStoryGraphNavigator tutorialStoryGraphNavigator)
		{
			tutorialStoryGraphNavigator.tutorial_references.pins_controller.addPinsOnBoard(pin_positions);
			progressNextAction(_navigator);
		}
		else
		{
			Debug.LogError("Cannot put pins on board without a tutorial story graph navigator!");
			progressNextAction(_navigator);
		}
	}
}
