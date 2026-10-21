using GRGLib.PropertyDrawers;
using Tutorial;
using UnityEngine;

namespace Nodes;

public class DeleteObjectOnTutorialEventNode : StoryEventNodeBase
{
	[SerializeField]
	private string key;

	[SerializeField]
	private bool use_message_call;

	[SerializeField]
	[ConditionalField("use_message_call")]
	private string message;

	public override void immidiateEvent(IEventsRunner _controller)
	{
		if (_controller is TutorialEventsRunner tutorialEventsRunner)
		{
			if (use_message_call)
			{
				tutorialEventsRunner.messageObjectForRemoval(key, message);
			}
			else
			{
				tutorialEventsRunner.deleteObject(key);
			}
		}
		else
		{
			Debug.LogError("Trying to use a tutorial event node without a tutorial event runner!");
		}
	}
}
