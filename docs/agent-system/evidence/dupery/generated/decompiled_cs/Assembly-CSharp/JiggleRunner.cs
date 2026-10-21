using System.Collections.Generic;
using GRGLib.Coroutines;
using GRGLib.Maybe;
using UnityEngine;

public class JiggleRunner : MonoBehaviour
{
	[SerializeField]
	private List<Transform> jiggle_transforms = new List<Transform>();

	[SerializeField]
	private Vector2 jiggle_range = new Vector2(8f, 12f);

	private Maybe<Coroutine> jiggle_coroutine = new Maybe<Coroutine>();

	public void jiggle()
	{
		if (!jiggle_coroutine.is_some)
		{
			jiggle_coroutine = new Maybe<Coroutine>(Jiggler.jiggleAnim(this, jiggle_transforms, jiggle_range).addCallback(delegate
			{
				jiggle_coroutine = new Maybe<Coroutine>();
			}).start(this));
		}
	}

	public void stopJiggling()
	{
		if (jiggle_coroutine.is_some)
		{
			StopCoroutine(jiggle_coroutine.value);
			jiggle_coroutine = new Maybe<Coroutine>();
		}
	}

	public List<Transform> getJiggleTransforms()
	{
		return jiggle_transforms;
	}
}
