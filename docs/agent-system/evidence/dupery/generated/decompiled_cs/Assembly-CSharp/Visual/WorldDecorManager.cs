using System;
using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Random;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class WorldDecorManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private RectTransform top_layer_shadow;

	[SerializeField]
	private RectTransform bottom_layer_shadow;

	[SerializeField]
	private Image full_dark;

	private System.Random rng = RandomExtensions.freshRandom();

	private bool flickered;

	public void Start()
	{
		moveLightsSlightly().start(this);
	}

	private IEnumerator moveLightsSlightly()
	{
		float top_starting_pivot = top_layer_shadow.localEulerAngles.z;
		float bot_starting_pivot = bottom_layer_shadow.localEulerAngles.z;
		while (true)
		{
			float duration = rng.nextFloat(6f, 8f);
			float num = rng.nextFloat(0.5f, 1.25f);
			top_layer_shadow.rotateTransformSmart(top_starting_pivot + num, duration, CoroutineExtensions.easeInOutFunc).start(this);
			bottom_layer_shadow.rotateTransformSmart(bot_starting_pivot + num, duration, CoroutineExtensions.easeInOutFunc).start(this);
			yield return duration.wait();
			rollDark().start(this);
			duration = rng.nextFloat(6f, 8f);
			num = rng.nextFloat(0.5f, 1.25f);
			top_layer_shadow.rotateTransformDirection(top_starting_pivot - num, duration, _clockwise: true, CoroutineExtensions.easeInOutFunc).start(this);
			bottom_layer_shadow.rotateTransformSmart(bot_starting_pivot - num, duration, CoroutineExtensions.easeInOutFunc).start(this);
			yield return duration.wait();
			rollDark().start(this);
		}
	}

	private IEnumerator rollDark()
	{
		if (!flickered && rng.Next(0, 100) <= 2)
		{
			flickered = true;
			yield return full_dark.fade(1f, 0.05f, CoroutineExtensions.easeInOutFunc);
			yield return 0.1f.wait();
			yield return full_dark.fade(0f, 0.05f, CoroutineExtensions.easeInOutFunc);
			yield return 0.2f.wait();
			yield return full_dark.fade(1f, 0.05f, CoroutineExtensions.easeInOutFunc);
			yield return 0.25f.wait();
			yield return full_dark.fade(0f, 0.05f, CoroutineExtensions.easeInOutFunc);
			yield return rng.nextFloat(0.5f, 1f).wait();
			yield return full_dark.fade(1f, 0.05f, CoroutineExtensions.easeInOutFunc);
			yield return rng.nextFloat(0.5f, 1.25f).wait();
			yield return full_dark.fade(0f, 0.05f, CoroutineExtensions.easeInOutFunc);
			yield return 0.1f.wait();
			yield return full_dark.fade(1f, 0.05f, CoroutineExtensions.easeInOutFunc);
			yield return 0.1f.wait();
			yield return full_dark.fade(0f, 0.05f, CoroutineExtensions.easeInOutFunc);
		}
	}
}
