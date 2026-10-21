using System;
using GRGLib.Extensions.Random;
using UnityEngine;

namespace GRGLib.Generic;

[Serializable]
public struct MinMaxFloat
{
	public float min;

	public float max;

	public float average => (min + max) / 2f;

	public MinMaxFloat(float _min, float _max)
	{
		min = _min;
		max = _max;
	}

	public float get(System.Random _rng)
	{
		return _rng.nextFloat(min, max);
	}

	public float estimate(float _t)
	{
		return min + (max - min) * _t;
	}

	public bool inRange(float _value)
	{
		if (_value >= min)
		{
			return _value <= max;
		}
		return false;
	}

	public bool inRange(int _value)
	{
		if ((float)_value >= min)
		{
			return (float)_value <= max;
		}
		return false;
	}

	public static MinMaxFloat multiply(MinMaxFloat _min_max, float _value)
	{
		_min_max.min *= _value;
		_min_max.max *= _value;
		return _min_max;
	}

	public static implicit operator Vector2(MinMaxFloat _a)
	{
		return new Vector2(_a.min, _a.max);
	}

	public static implicit operator MinMaxFloat(Vector2 _a)
	{
		return new MinMaxFloat(_a.x, _a.y);
	}

	public static MinMaxFloat operator +(MinMaxFloat a, MinMaxFloat b)
	{
		a.min += b.min;
		a.max += b.max;
		return a;
	}

	public static MinMaxFloat operator -(MinMaxFloat v)
	{
		v.min = 0f - v.min;
		v.max = 0f - v.max;
		return v;
	}

	public static MinMaxFloat operator -(MinMaxFloat a, MinMaxFloat b)
	{
		a.min -= b.min;
		a.max -= b.max;
		return a;
	}

	public static MinMaxFloat operator *(MinMaxFloat a, float b)
	{
		a.min *= b;
		a.max *= b;
		return a;
	}

	public static MinMaxFloat operator *(float a, MinMaxFloat b)
	{
		b.min *= a;
		b.max *= a;
		return b;
	}

	public static MinMaxFloat operator *(MinMaxFloat a, MinMaxFloat b)
	{
		a.min *= b.min;
		a.max *= b.max;
		return a;
	}

	public static MinMaxFloat operator /(MinMaxFloat a, float b)
	{
		a.min /= b;
		a.max /= b;
		return a;
	}

	public static bool operator ==(MinMaxFloat lhs, MinMaxFloat rhs)
	{
		if (lhs.min == rhs.min)
		{
			return lhs.max == rhs.max;
		}
		return false;
	}

	public static bool operator !=(MinMaxFloat lhs, MinMaxFloat rhs)
	{
		if (lhs.min == rhs.min)
		{
			return lhs.max != rhs.max;
		}
		return true;
	}

	public override bool Equals(object obj)
	{
		if (obj.GetType() == typeof(MinMaxFloat))
		{
			return (MinMaxFloat)obj == this;
		}
		return false;
	}

	public override int GetHashCode()
	{
		return (17 * 23 + min.GetHashCode()) * 23 + max.GetHashCode();
	}

	public override string ToString()
	{
		return $"MinMaxFloat ({min}-{max})";
	}

	public string toString()
	{
		return $"{min}-{max}";
	}
}
