using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Serializable;
using UnityEngine;

public class BackgroundMenuAnimationManager : MonoBehaviour
{
	public enum BackgroundState
	{
		CLOSED,
		CLOSING,
		OPENING,
		OPEN,
		CUSTOM
	}

	[Serializable]
	public struct TransformAnimationTarget
	{
		public RectTransform transform;

		public Vector2 target;

		public float rotation;

		public IEnumerator animateMovement(float _duration, Func<float, float> _ease)
		{
			return transform.anchoredMove(target, _duration, _ease);
		}

		public IEnumerator animatedRotation(float _duration, Func<float, float> _ease)
		{
			return transform.rotateTransformSmart(rotation, _duration, _ease);
		}
	}

	[Header("Animation Settings")]
	[SerializeField]
	private CanvasGroup group;

	[SerializeField]
	private RectTransform slant;

	[SerializeField]
	private Vector2 start_slant_position;

	[SerializeField]
	private float animation_in_duration = 0.5f;

	[SerializeField]
	private float animation_out_duration = 0.5f;

	[SerializeField]
	private List<STupple<RectTransform, Vector2>> to_move;

	[SerializeField]
	private List<STupple<RectTransform, float>> to_rotate;

	[SerializeField]
	private SerializableDictionary<string, STupple<float, List<TransformAnimationTarget>>> custom_animations;

	private CoroutineRunner menuing_extra_runner;

	private MultiCoroutineRunner optional_runner;

	public BackgroundState state { get; private set; }

	protected void Awake()
	{
		menuing_extra_runner = new CoroutineRunner(this);
		optional_runner = new MultiCoroutineRunner(this);
	}

	public void openingMenuAnimation()
	{
		if (state != BackgroundState.OPENING && state != BackgroundState.OPEN)
		{
			state = BackgroundState.OPENING;
			group.alpha = 1f;
			menuing_extra_runner.run(slant.moveTransform(Vector3.zero, animation_in_duration, CoroutineExtensions.easeOutBackFunc).addCallback(delegate
			{
				state = BackgroundState.OPEN;
			}));
			optional_runner.run(to_move.Aggregate(new List<IEnumerator>(), (List<IEnumerator> _a, STupple<RectTransform, Vector2> _tm) => _a.add(_tm.Item1.anchoredMove(_tm.Item2, animation_in_duration, CoroutineExtensions.easeOutBackFunc))).addRange(to_rotate.Aggregate(new List<IEnumerator>(), (List<IEnumerator> _a, STupple<RectTransform, float> _tr) => _a.add(_tr.Item1.rotateTransformSmart(_tr.Item2, animation_in_duration, CoroutineExtensions.easeOutBackFunc)))).ToArray());
		}
	}

	public void closingMenuAnimation()
	{
		if (state != BackgroundState.CLOSING && state != 0)
		{
			state = BackgroundState.CLOSING;
			menuing_extra_runner.run(slant.moveTransform(start_slant_position, animation_out_duration, CoroutineExtensions.easeInOutBackFunc).addCallback(delegate
			{
				group.alpha = 0f;
				state = BackgroundState.CLOSED;
			}));
			optional_runner.run(to_move.Aggregate(new List<IEnumerator>(), (List<IEnumerator> _a, STupple<RectTransform, Vector2> _tm) => _a.add(_tm.Item1.anchoredMove(new Vector3(0f, 0f, 0f), animation_out_duration, CoroutineExtensions.easeInOutBackFunc))).addRange(to_rotate.Aggregate(new List<IEnumerator>(), (List<IEnumerator> _a, STupple<RectTransform, float> _tr) => _a.add(_tr.Item1.rotateTransformSmart(0f, animation_out_duration, CoroutineExtensions.easeInOutBackFunc)))).ToArray());
		}
	}

	public float getAnimationDuration(bool _in)
	{
		if (!_in)
		{
			return animation_out_duration;
		}
		return animation_in_duration;
	}

	public float animateBackground(string _animation_key)
	{
		state = BackgroundState.CUSTOM;
		float duration = custom_animations[_animation_key].Item1;
		optional_runner.run(custom_animations[_animation_key].Item2.Aggregate(new List<IEnumerator>(), (List<IEnumerator> _a, TransformAnimationTarget _anim) => _a.add(_anim.animateMovement(duration, CoroutineExtensions.easeOutBackFunc)).add(_anim.animatedRotation(duration, CoroutineExtensions.easeOutBackFunc))).ToArray());
		return duration;
	}
}
