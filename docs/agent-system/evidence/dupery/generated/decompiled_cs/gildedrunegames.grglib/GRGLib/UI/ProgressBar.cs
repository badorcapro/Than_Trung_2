using System;
using System.Collections;
using GRGLib.Coroutines;
using UnityEngine;

namespace GRGLib.UI;

[RequireComponent(typeof(RectTransform))]
[AddComponentMenu("GRGLib/UI/ProgressBar")]
public class ProgressBar : MonoBehaviour
{
	[Header("Settings")]
	[SerializeField]
	protected bool horizontal_bar = true;

	[Header("Reference")]
	[SerializeField]
	protected RectTransform bar;

	protected CoroutineRunner bar_runner;

	protected virtual void Awake()
	{
		bar_runner = new CoroutineRunner(this);
	}

	public void setProgressInstant(float _value, float _max)
	{
		setProgressInstant(_value, 0f, _max);
	}

	public void setProgressInstant(float _value, float _min, float _max)
	{
		setProgress(_value, _min, _max, setBarProgressInstant);
	}

	public void setProgress(float _value, float _max)
	{
		setProgress(_value, 0f, _max);
	}

	public void setProgress(float _value, float _min, float _max)
	{
		setProgress(_value, _min, _max, setBarProgress);
	}

	private void setProgress(float _value, float _min, float _max, Action<float, float, float> _set_bar)
	{
		if (_max - _min == 0f)
		{
			Debug.LogError("Trying to set progress bar with a (max - min) value of 0! This is not allowed!");
			_max += 0.1f;
		}
		if (_value > _max)
		{
			_value = _max;
		}
		_set_bar(_value, _min, _max);
		onProgressSet(_value, _min, _max);
	}

	protected virtual void setBarProgressInstant(float _value, float _min, float _max)
	{
		bar.anchorMax = getMaxAnchor(_value, _min, _max);
	}

	protected virtual void setBarProgress(float _value, float _min, float _max)
	{
		bar_runner.run(setProgressAnimation(bar, getMaxAnchor(_value, _min, _max)));
	}

	protected virtual void onProgressSet(float _value, float _min, float _max)
	{
	}

	protected virtual IEnumerator setProgressAnimation(RectTransform _bar, Vector2 _anchor_max)
	{
		yield return _bar.anchoredMaxScale(_anchor_max, 0.35f, CoroutineExtensions.easeInOutFunc);
	}

	protected Vector2 getMaxAnchor(float _value, float _min, float _max)
	{
		if (!horizontal_bar)
		{
			return new Vector2(1f, normalisedProgress(_value, _min, _max));
		}
		return new Vector2(normalisedProgress(_value, _min, _max), 1f);
	}

	public static float normalisedProgress(float _value, float _min, float _max)
	{
		return (_value - _min) / (_max - _min);
	}
}
