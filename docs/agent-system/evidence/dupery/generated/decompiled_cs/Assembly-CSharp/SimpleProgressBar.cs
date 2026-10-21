using System.Collections;
using GRGLib.Coroutines;
using GRGLib.UI;
using UnityEngine;

public class SimpleProgressBar : ProgressBarText
{
	[Header("Animation Settings")]
	[SerializeField]
	private float fill_duration = 0.5f;

	protected override IEnumerator setProgressAnimation(RectTransform _bar, Vector2 _anchor_max)
	{
		yield return _bar.anchoredMaxScale(_anchor_max, fill_duration, CoroutineExtensions.easeInOutFunc);
	}
}
