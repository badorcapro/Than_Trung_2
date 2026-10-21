using GRGLib.Coroutines;
using UnityEngine;

namespace Lineup;

public class LineupArrow : MonoBehaviour
{
	[SerializeField]
	private bool should_flip;

	[SerializeField]
	[Range(1f, 1.5f)]
	private float scale_factor = 1.1f;

	private CoroutineRunner bob_runner;

	private void Awake()
	{
		bob_runner = new CoroutineRunner(this);
	}

	public void scale(bool _up)
	{
		bob_runner.run(base.gameObject.transform.scaleTransform((_up ? scale_factor : 1f) * (should_flip ? (-1f) : 1f), 0.2f, CoroutineExtensions.easeInOutFunc));
	}
}
