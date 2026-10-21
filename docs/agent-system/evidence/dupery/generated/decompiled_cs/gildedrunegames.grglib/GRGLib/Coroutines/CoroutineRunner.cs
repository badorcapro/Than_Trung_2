using System.Collections;
using GRGLib.Maybe;
using UnityEngine;

namespace GRGLib.Coroutines;

public class CoroutineRunner
{
	protected MonoBehaviour mono { get; private set; }

	protected Maybe<Coroutine> coroutine { get; private set; } = new Maybe<Coroutine>();

	public virtual bool is_running => coroutine.is_some;

	public CoroutineRunner(MonoBehaviour _mono)
	{
		mono = _mono;
	}

	public void run(IEnumerator _coroutine)
	{
		stop();
		runWithoutStopping(_coroutine);
	}

	public void runIfNot(IEnumerator _coroutine)
	{
		if (!coroutine.is_some)
		{
			runWithoutStopping(_coroutine);
		}
	}

	public virtual void runWithoutStopping(IEnumerator _coroutine)
	{
		coroutine = _coroutine.addCallback(coroutineEnded).start(mono).maybe();
	}

	public virtual void stop()
	{
		if (coroutine.is_some)
		{
			coroutine.value.stop(mono);
			coroutine = new Maybe<Coroutine>();
		}
	}

	protected virtual void coroutineEnded()
	{
		coroutine = new Maybe<Coroutine>();
	}
}
