using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using GRGLib.PropertyDrawers;
using UnityEngine;

namespace GRGLib.UI;

[AddComponentMenu("GRGLib/UI/ProgressBarTextDoubled")]
public class ProgressBarTextDoubled : ProgressBarText
{
	[Header("Second Bar Settings")]
	[SerializeField]
	protected RectTransform second_bar;

	[SerializeField]
	protected bool smooth_transition = true;

	[SerializeField]
	[ConditionalField("smooth_transition")]
	private float bar_1_duration = 1f;

	[SerializeField]
	[ConditionalField("smooth_transition")]
	private float bar_2_duration = 1f;

	[SerializeField]
	protected float second_bar_delay = 0.5f;

	private Maybe<Coroutine> progress_animation = new Maybe<Coroutine>();

	protected override void setBarProgress(float _value, float _min, float _max)
	{
		Vector2 anchor_target = (horizontal_bar ? new Vector2((_value - _min) / (_max - _min), 1f) : new Vector2(1f, (_value - _min) / (_max - _min)));
		progress_animation.stopCoroutineIfSome(this);
		progress_animation = (smooth_transition ? smoothProgressAnimation(anchor_target, bar_1_duration, bar_2_duration) : noneSmoothProgressAnimation(anchor_target)).addCallback(delegate
		{
			progress_animation = new Maybe<Coroutine>();
		}).start(this).maybe();
	}

	protected override void setBarProgressInstant(float _value, float _min, float _max)
	{
		base.setBarProgressInstant(_value, _min, _max);
		second_bar.anchorMax = bar.anchorMax;
	}

	private IEnumerator smoothProgressAnimation(Vector2 _anchor_target, float _duration_1, float _duration_2)
	{
		return ProgressBarDoubled.smoothProgress(second_bar, bar, _anchor_target, _duration_1, _duration_2, second_bar_delay);
	}

	private IEnumerator noneSmoothProgressAnimation(Vector2 _anchor_target)
	{
		return ProgressBarDoubled.noneSmoothProgress(second_bar, bar, _anchor_target, second_bar_delay);
	}
}
