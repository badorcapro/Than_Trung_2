using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Collections;
using GRGLib.Maybe;
using UnityEngine;

public class ParalaxAnimationManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField]
	private List<ParalaxAnimatedObject> paralax_objects;

	private MultiCoroutineRunner paralax_animations_runner;

	protected virtual void Awake()
	{
		paralax_animations_runner = new MultiCoroutineRunner(this);
	}

	public float animateObjects(string _animation_key)
	{
		(List<IEnumerator>, float) tuple = paralax_objects.Aggregate((new List<IEnumerator>(), 0f), delegate((List<IEnumerator>, float) _a, ParalaxAnimatedObject _p)
		{
			Maybe<ParalaxAnimatedObject.AnimationTarget> paralaxMovement = _p.getParalaxMovement(_animation_key);
			if (paralaxMovement.is_some)
			{
				_a.Item1.add(paralaxMovement.value.animateMovement(_p.rect_trans)).add(paralaxMovement.value.animatedRotation(_p.rect_trans));
				if (paralaxMovement.value.duration > _a.Item2)
				{
					_a = (_a.Item1, paralaxMovement.value.duration);
				}
			}
			return _a;
		});
		paralax_animations_runner.run(tuple.Item1.ToArray());
		return tuple.Item2;
	}

	private void Reset()
	{
		paralax_objects = GetComponentsInChildren<ParalaxAnimatedObject>().ToList();
	}
}
