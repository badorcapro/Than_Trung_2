using System;
using UnityEngine;

namespace GRGLib.Generic;

[Serializable]
public struct MinMaxInt
{
	public int min;

	public int max;

	public float average => (float)(min + max) / 2f;

	public MinMaxInt(int _min, int _max)
	{
		min = _min;
		max = _max;
	}

	public int get(System.Random _rng)
	{
		return _rng.Next(min, max + 1);
	}

	public float estimate(float _t)
	{
		return (float)min + (float)(max - min) * _t;
	}

	public bool inRange(float _value)
	{
		if (_value >= (float)min)
		{
			return _value <= (float)max;
		}
		return false;
	}

	public bool inRange(int _value)
	{
		if (_value >= min)
		{
			return _value <= max;
		}
		return false;
	}

	public static MinMaxInt multiply(MinMaxInt _min_max, float _value, Func<float, int> _rounding)
	{
		_min_max.min = _rounding((float)_min_max.min * _value);
		_min_max.max = _rounding((float)_min_max.max * _value);
		return _min_max;
	}

	public static implicit operator Vector2Int(MinMaxInt _a)
	{
		return new Vector2Int(_a.min, _a.max);
	}

	public static implicit operator MinMaxInt(Vector2Int _a)
	{
		return new MinMaxInt(_a.x, _a.y);
	}

	public static MinMaxInt operator +(MinMaxInt a, MinMaxInt b)
	{
		a.min += b.min;
		a.max += b.max;
		return a;
	}

	public static MinMaxInt operator -(MinMaxInt v)
	{
		v.min = -v.min;
		v.max = -v.max;
		return v;
	}

	public static MinMaxInt operator -(MinMaxInt a, MinMaxInt b)
	{
		a.min -= b.min;
		a.max -= b.max;
		return a;
	}

	public static MinMaxInt operator *(MinMaxInt a, int b)
	{
		a.min *= b;
		a.max *= b;
		return a;
	}

	public static MinMaxInt operator *(int a, MinMaxInt b)
	{
		b.min *= a;
		b.max *= a;
		return b;
	}

	public static MinMaxInt operator *(MinMaxInt a, MinMaxInt b)
	{
		a.min *= b.min;
		a.max *= b.max;
		return a;
	}

	public static MinMaxInt operator /(MinMaxInt a, int b)
	{
		a.min /= b;
		a.max /= b;
		return a;
	}

	public static bool operator ==(MinMaxInt lhs, MinMaxInt rhs)
	{
		if (lhs.min == rhs.min)
		{
			return lhs.max == rhs.max;
		}
		return false;
	}

	public static bool operator !=(MinMaxInt lhs, MinMaxInt rhs)
	{
		if (lhs.min == rhs.min)
		{
			return lhs.max != rhs.max;
		}
		return true;
	}

	public override bool Equals(object obj)
	{
		if (obj.GetType() == typeof(MinMaxInt))
		{
			return (MinMaxInt)obj == this;
		}
		return false;
	}

	public override int GetHashCode()
	{
		return (17 * 23 + min.GetHashCode()) * 23 + max.GetHashCode();
	}

	public override string ToString()
	{
		return $"MinMaxInt ({min}-{max})";
	}

	public string toString()
	{
		return $"{min}-{max}";
	}
}
