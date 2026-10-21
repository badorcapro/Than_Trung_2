using System.Collections;
using GRGLib.Coroutines;
using Tutorial;
using UnityEngine;
using Visual;
using XNode;

namespace Nodes;

public class TutorialWaitForSceneState : StoryNodeBase, INodeActionMarker
{
	public enum SceneState
	{
		LINE_ERASED,
		PINS_REMOVED
	}

	[Input(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase enter;

	[Output(ShowBackingValue.Never, ConnectionType.Multiple, TypeConstraint.None, false)]
	public StoryNodeBase exit;

	[SerializeField]
	private SceneState state;

	public override void progress(IStoryGraphNavigator _navigator)
	{
		TutorialStoryGraphNavigator tuto_navig = _navigator as TutorialStoryGraphNavigator;
		if (tuto_navig != null)
		{
			tuto_navig.handler.startWait();
			switch (state)
			{
			case SceneState.LINE_ERASED:
				waitForLines(tuto_navig.tutorial_references.pen_manager, tuto_navig.tutorial_references.rubber_manager).addCallback(delegate
				{
					progressNext(tuto_navig);
				}).start(tuto_navig.handler);
				break;
			case SceneState.PINS_REMOVED:
				waitForPins(tuto_navig.tutorial_references.pins_controller).addCallback(delegate
				{
					progressNext(tuto_navig);
				}).start(tuto_navig.handler);
				break;
			default:
				Debug.LogError($"No wait function set up for scene state {state}!");
				progressNext(tuto_navig);
				break;
			}
		}
		else
		{
			Debug.LogError("Cant wait for case state without a tutorial story graph navigator!!!");
			progressNextAction(_navigator);
		}
	}

	private void progressNext(TutorialStoryGraphNavigator _navigator)
	{
		_navigator.handler.endWait();
		progressNextAction(_navigator);
	}

	private IEnumerator waitForLines(PenManager _pen_manager, RubberManager _rubber)
	{
		while (_pen_manager.hasAnyLine())
		{
			yield return null;
		}
		_rubber.deselectPen();
	}

	private IEnumerator waitForPins(PinsController _pins_controller)
	{
		while (_pins_controller.hasAnyPin())
		{
			yield return null;
		}
	}
}
