using System.Collections;
using GRGLib.Coroutines;
using UnityEngine;
using UnityEngine.UI;

namespace TransitionScene;

public class SyndicateTransitionSceneDecor : TransitionSceneDecor
{
	[Header("References")]
	[SerializeField]
	private Image background;

	[SerializeField]
	private Image background_2;

	[Header("Settings")]
	[SerializeField]
	private Vector2 destination;

	[SerializeField]
	private float movement_duration = 4f;

	[SerializeField]
	private float scale = 1f;

	[SerializeField]
	private float scale_duration = 2.5f;

	public override void setUp()
	{
		background.transform.moveTransform(destination, movement_duration, CoroutineExtensions.easeInOutFunc).start(this);
		background.transform.scaleTransform(scale, scale_duration, CoroutineExtensions.easeInOutFunc).start(this);
		flashLight().start(this);
	}

	private IEnumerator flashLight()
	{
		yield return 3.5f.wait();
		yield return background_2.fade(0.5f, 0.5f, CoroutineExtensions.easeInOutFunc);
		yield return 0.1f.wait();
		yield return background_2.fade(0f, 0.25f, CoroutineExtensions.easeInOutFunc);
		yield return 0.4f.wait();
		yield return background_2.fade(1f, 0.1f, CoroutineExtensions.easeInOutFunc);
		yield return background_2.fade(0f, 0.1f, CoroutineExtensions.easeInOutFunc);
		yield return background_2.fade(1f, 0.15f, CoroutineExtensions.easeInOutFunc);
	}
}
