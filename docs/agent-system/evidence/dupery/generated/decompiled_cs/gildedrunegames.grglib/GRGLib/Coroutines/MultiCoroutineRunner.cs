using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace GRGLib.Coroutines;

public class MultiCoroutineRunner : CoroutineRunner
{
	private HashSet<Coroutine> running_coroutines = new HashSet<Coroutine>();

	public override bool is_running
	{
		get
		{
			if (!base.is_running)
			{
				return running_coroutines.Count > 0;
			}
			return true;
		}
	}

	public MultiCoroutineRunner(MonoBehaviour _mono)
		: base(_mono)
	{
	}

	public void run(params IEnumerator[] _coroutines)
	{
		if (_coroutines.Length == 0)
		{
			Debug.LogWarning("Trying to play 0 coroutines!");
			return;
		}
		stop();
		foreach (IEnumerator enumerator in _coroutines)
		{
			Coroutine running = null;
			running = enumerator.addCallback(delegate
			{
				running_coroutines.Remove(running);
			}).start(base.mono);
			running_coroutines.Add(running);
		}
	}

	public override void stop()
	{
		base.stop();
		foreach (Coroutine running_coroutine in running_coroutines)
		{
			running_coroutine.stop(base.mono);
		}
		running_coroutines.Clear();
	}
}
