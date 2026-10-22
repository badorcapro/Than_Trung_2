using System;
using GRGLib.Maybe;
using UnityEngine;

[Serializable]
public class Either<T1, T2>
{
	[SerializeField]
	[HideInInspector]
	private T1 a_val;

	[SerializeField]
	[HideInInspector]
	private T2 b_val;

	[SerializeField]
	[HideInInspector]
	private bool _is_a;

	public Maybe<T1> maybe_a
	{
		get
		{
			if (!_is_a)
			{
				return new Maybe<T1>();
			}
			return new Maybe<T1>(a_val);
		}
	}

	public Maybe<T2> maybe_b
	{
		get
		{
			if (!_is_a)
			{
				return new Maybe<T2>(b_val);
			}
			return new Maybe<T2>();
		}
	}

	public bool is_a => _is_a;

	public bool is_b => !is_a;

	public Either(T1 _a_val)
	{
		a_val = _a_val;
		_is_a = true;
	}

	public Either(T2 _b_val)
	{
		b_val = _b_val;
		_is_a = false;
	}
}
