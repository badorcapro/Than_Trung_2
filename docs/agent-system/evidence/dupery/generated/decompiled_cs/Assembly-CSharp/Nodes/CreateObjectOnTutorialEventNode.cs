using Tutorial;
using UnityEngine;

namespace Nodes;

public class CreateObjectOnTutorialEventNode : StoryEventNodeBase
{
	[SerializeField]
	private string key;

	[SerializeField]
	private GameObject prefab;

	public override void immidiateEvent(IEventsRunner _controller)
	{
		if (_controller is TutorialEventsRunner tutorialEventsRunner)
		{
			tutorialEventsRunner.createObject(prefab, key);
		}
		else
		{
			Debug.LogError("Trying to use a tutorial event node without a tutorial event runner!");
		}
	}
}
