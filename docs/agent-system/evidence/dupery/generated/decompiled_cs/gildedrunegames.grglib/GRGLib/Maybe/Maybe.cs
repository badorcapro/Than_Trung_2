using System;
using UnityEngine;

namespace GRGLib.Maybe;

[Serializable]
public class Maybe<T>
{
	[SerializeField]
	[HideInInspector]
	private T _value;

	[SerializeField]
	[HideInInspector]
	private bool _is_some;

	public T value
	{
		get
		{
			return _value;
		}
		private set
		{
			_value = value;
		}
	}

	public bool is_some
	{
		get
		{
			return _is_some;
		}
		private set
		{
			_is_some = value;
		}
	}

	public Maybe(T _val)
	{
		value = _val;
		is_some = true;
	}

	public Maybe()
	{
		is_some = false;
	}

	public Maybe<A> fmap<A>(Func<T, A> _func)
	{
		if (is_some)
		{
			return new Maybe<A>(_func(value));
		}
		return new Maybe<A>();
	}

	public Maybe<A> bind<A>(Func<T, Maybe<A>> _func)
	{
		if (is_some)
		{
			return _func(value);
		}
		return new Maybe<A>();
	}
}
