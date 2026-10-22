using System.Collections;
using GRGLib.Coroutines;
using UnityEngine;

namespace TransitionScene;

public class OfficeTransitionDecor : TransitionSceneDecor
{
	[SerializeField]
	private RectTransform detective;

	[SerializeField]
	private RectTransform ltective;

	[SerializeField]
	private RectTransform dust;

	[SerializeField]
	private RectTransform background;

	private void Start()
	{
		StartCoroutine(decorAnm(8f));
	}

	private IEnumerator decorAnm(float _duration)
	{
		ltective.anchoredMove(new Vector3(151.7f, -20f, 0f), _duration, CoroutineExtensions.easeInOutFunc).start(this);
		dust.anchoredMove(new Vector3(0f, 0f, 0f), _duration, CoroutineExtensions.easeInOutFunc).start(this);
		background.anchoredMove(new Vector3(-5f, -5f, 0f), _duration, CoroutineExtensions.easeInOutFunc).start(this);
		yield return detective.anchoredMove(new Vector3(-109f, -36f, 0f), _duration, CoroutineExtensions.easeInOutFunc);
	}
}
