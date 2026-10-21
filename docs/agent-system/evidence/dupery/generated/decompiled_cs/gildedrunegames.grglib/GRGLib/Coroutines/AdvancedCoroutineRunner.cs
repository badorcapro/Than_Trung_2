using System;
using System.Collections;
using System.Collections.Generic;
using GRGLib.Maybe;
using UnityEngine;

namespace GRGLib.Coroutines;

public class AdvancedCoroutineRunner : CoroutineRunner
{
	private Maybe<Action> callback = new Maybe<Action>();

	private bool unique_callback;

	private Queue<IEnumerator> coroutine_queue = new Queue<IEnumerator>();

	public AdvancedCoroutineRunner(MonoBehaviour _mono)
		: base(_mono)
	{
	}

	public void runOrQueue(IEnumerator _coroutine)
	{
		if (is_running)
		{
			run(_coroutine);
			return;
		}
		queue(_coroutine);
	}

	public void queue(params IEnumerator[] _coroutines)
	{
		for (int i = 0; i < _coroutines.Length; i++)
		{
			coroutine_queue.Enqueue(_coroutines[i]);
		}
	}

	public void run(IEnumerator _coroutine, Action _callback)
	{
		run(_coroutine);
		addCallback(_callback);
	}

	public void addCallback(Action _callback, bool _is_unique = true)
	{
		unique_callback = _is_unique;
		callback = _callback.maybe();
	}

	public void resetCallback()
	{
		unique_callback = true;
		callback = new Maybe<Action>();
	}

	public void stopAndContinue(bool _do_callback = false)
	{
		stop();
		if (_do_callback && callback.is_some)
		{
			callback.value();
			if (unique_callback)
			{
				callback = new Maybe<Action>();
			}
		}
		checkQueue();
	}

	public override void stop()
	{
		base.stop();
		if (unique_callback && callback.is_some)
		{
			callback = new Maybe<Action>();
		}
	}

	protected override void coroutineEnded()
	{
		base.coroutineEnded();
		if (callback.is_some)
		{
			callback.value();
			if (unique_callback)
			{
				callback = new Maybe<Action>();
			}
		}
		checkQueue();
	}

	private void checkQueue()
	{
		if (coroutine_queue.Count > 0)
		{
			run(coroutine_queue.Dequeue());
		}
	}
}
