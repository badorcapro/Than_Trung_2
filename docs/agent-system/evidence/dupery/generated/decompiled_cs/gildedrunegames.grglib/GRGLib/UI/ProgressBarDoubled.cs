using System.Collections;
using GRGLib.Coroutines;
using GRGLib.PropertyDrawers;
using UnityEngine;

namespace GRGLib.UI;

[AddComponentMenu("GRGLib/UI/ProgressBarDoubled")]
public class ProgressBarDoubled : ProgressBar
{
	[Header("Second Bar Settings")]
	[SerializeField]
	protected RectTransform second_bar;

	[SerializeField]
	protected bool smooth_transition;

	[SerializeField]
	[ConditionalField("smooth_transition")]
	private float bar_1_duration;

	[SerializeField]
	[ConditionalField("smooth_transition")]
	private float bar_2_duration;

	[SerializeField]
	protected float second_bar_delay;

	protected override void setBarProgressInstant(float _value, float _min, float _max)
	{
		base.setBarProgressInstant(_value, _min, _max);
		second_bar.anchorMax = bar.anchorMax;
	}

	protected override IEnumerator setProgressAnimation(RectTransform _bar, Vector2 _target)
	{
		if (!smooth_transition)
		{
			return noneSmoothProgressAnimation(_target);
		}
		return smoothProgressAnimation(_target, bar_1_duration, bar_2_duration);
	}

	private IEnumerator smoothProgressAnimation(Vector2 _anchor_target, float _duration_1, float _duration_2)
	{
		return smoothProgress(second_bar, bar, _anchor_target, _duration_1, _duration_2, second_bar_delay);
	}

	private IEnumerator noneSmoothProgressAnimation(Vector2 _anchor_target)
	{
		return noneSmoothProgress(second_bar, bar, _anchor_target, second_bar_delay);
	}

	public static IEnumerator smoothProgress(RectTransform _second_bar, RectTransform _bar, Vector2 _anchor_target, float _duration_1, float _duration_2, float _second_bar_delay)
	{
		yield return _second_bar.anchoredMaxScale(_anchor_target, _duration_1, CoroutineExtensions.easeInOutFunc);
		yield return _second_bar_delay.wait();
		yield return _bar.anchoredMaxScale(_anchor_target, _duration_2, CoroutineExtensions.easeInOutFunc);
	}

	public static IEnumerator noneSmoothProgress(RectTransform _second_bar, RectTransform _bar, Vector2 _anchor_target, float _second_bar_delay)
	{
		_second_bar.anchorMax = _anchor_target;
		yield return _second_bar_delay.wait();
		_bar.anchorMax = _anchor_target;
	}
}
