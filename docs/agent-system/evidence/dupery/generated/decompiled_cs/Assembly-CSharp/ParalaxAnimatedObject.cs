using System;
using System.Collections;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using GRGLib.Serializable;
using UnityEngine;

public class ParalaxAnimatedObject : MonoBehaviour
{
	[Serializable]
	public struct AnimationTarget
	{
		public float duration;

		public Vector2 target;

		public float rotation;

		public CoroutineEasing movement_coroutine_easing;

		public CoroutineEasing rotation_coroutine_easing;

		public IEnumerator animateMovement(RectTransform _trans)
		{
			return _trans.anchoredMove(target, duration, movement_coroutine_easing.getEaseFunc());
		}

		public IEnumerator animatedRotation(RectTransform _trans)
		{
			return _trans.rotateTransformSmart(rotation, duration, rotation_coroutine_easing.getEaseFunc());
		}
	}

	[Header("Settings")]
	[SerializeField]
	private SerializableDictionary<string, AnimationTarget> paralax_movements;

	public RectTransform rect_trans => base.transform as RectTransform;

	public Maybe<AnimationTarget> getParalaxMovement(string _key)
	{
		return paralax_movements.tryGet(_key);
	}
}
