using Tutorial;
using UnityEngine;

namespace Nodes;

public class CreateToolTipTutorialEventNode : StoryEventNodeBase
{
	[SerializeField]
	private string key;

	[SerializeField]
	private TutorialTooltip prefab;

	public override void immidiateEvent(IEventsRunner _controller)
	{
		if (_controller is TutorialEventsRunner tutorialEventsRunner)
		{
			tutorialEventsRunner.createObject(prefab.gameObject, key).GetComponent<TutorialTooltip>().setUpAndStart(tutorialEventsRunner.tutorial_handler.player_input);
		}
		else
		{
			Debug.LogError("Trying to use a tutorial event node without a tutorial event runner!");
		}
	}
}
