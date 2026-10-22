using System.Collections;
using GRGLib.Coroutines;
using GRGLib.PropertyDrawers;
using Tutorial;
using UnityEngine;

namespace Nodes;

public class BackgroundHoleTutorialEventNode : StoryEventNodeBase
{
	[SerializeField]
	private bool grow = true;

	[SerializeField]
	[ConditionalField("grow")]
	private Vector2 hole_size;

	[SerializeField]
	[ConditionalField("grow")]
	private Vector2 hole_position;

	public override IEnumerator eventCoroutine(IEventsRunner _controller)
	{
		if (!(_controller is TutorialEventsRunner _event_runner))
		{
			yield break;
		}
		if (grow)
		{
			if (_event_runner.tutorial_handler.hasBackgroundMaterial())
			{
				_event_runner.tutorial_references.background_image.material.lerpMaterialProperty("_Position", hole_position, 0.25f, CoroutineExtensions.easeInOutFunc).start(_event_runner.coroutine_mono);
			}
			else
			{
				_event_runner.tutorial_handler.addBackgroundMaterial();
				_event_runner.tutorial_references.background_image.material.SetVector("_Position", hole_position);
			}
		}
		yield return _event_runner.tutorial_references.background_image.material.lerpMaterialProperty("_Size", grow ? hole_size : Vector2.zero, 0.25f, CoroutineExtensions.easeInOutFunc);
		if (!grow)
		{
			_event_runner.tutorial_handler.removeBackgroundMaterial();
		}
	}

	public override void immidiateEvent(IEventsRunner _controller)
	{
		if (_controller is TutorialEventsRunner tutorialEventsRunner)
		{
			if (grow)
			{
				tutorialEventsRunner.tutorial_handler.addBackgroundMaterial();
				tutorialEventsRunner.tutorial_references.background_image.material.SetVector("_Position", hole_position);
				tutorialEventsRunner.tutorial_references.background_image.material.SetVector("_Size", hole_size);
			}
			else
			{
				tutorialEventsRunner.tutorial_references.background_image.material.SetVector("_Size", new Vector2(0f, 0f));
				tutorialEventsRunner.tutorial_handler.removeBackgroundMaterial();
			}
		}
	}
}
