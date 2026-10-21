using System;
using System.Collections.Generic;
using UnityEngine;

namespace GRGLib.Extensions.Numbers;

public static class IntegerExtension
{
	public static bool compareInt(this int _value, NumberComparaison _comparator, int _to_compare)
	{
		return _comparator switch
		{
			NumberComparaison.BELOW => _value < _to_compare, 
			NumberComparaison.ABOVE => _value > _to_compare, 
			NumberComparaison.EXACT => _value == _to_compare, 
			NumberComparaison.EXACT_AND_ABOVE => _value >= _to_compare, 
			NumberComparaison.EXACT_AND_BELOW => _value <= _to_compare, 
			_ => throw new ArgumentException($"Cannot find comparator: {_comparator}. In IntigerExtension.compareInt()"), 
		};
	}

	public static (int, int) seperateFirstDigit(this int _number)
	{
		int num = _number;
		if (num >= 100000000)
		{
			num /= 100000000;
		}
		if (num >= 10000)
		{
			num /= 10000;
		}
		if (num >= 100)
		{
			num /= 100;
		}
		if (num >= 10)
		{
			num /= 10;
		}
		int num2 = num;
		if (num2 * 100000000 <= _number)
		{
			num2 *= 100000000;
		}
		if (num2 * 10000 <= _number)
		{
			num2 *= 10000;
		}
		if (num2 * 100 <= _number)
		{
			num2 *= 100;
		}
		if (num2 * 10 <= _number)
		{
			num2 *= 10;
		}
		return (num, _number - num2);
	}

	public static int countDigits(this int _number)
	{
		int num = 0;
		while (_number >= 10)
		{
			_number /= 10;
			num++;
		}
		return num + 1;
	}

	public static List<int> splitDigits(this int _number)
	{
		List<int> list = new List<int>();
		int number = -1;
		while (_number >= 10)
		{
			number = _number;
			(int, int) tuple = _number.seperateFirstDigit();
			list.Add(tuple.Item1);
			_number = tuple.Item2;
		}
		if (_number == 0)
		{
			for (int i = 2; i < number.countDigits(); i++)
			{
				list.Add(0);
			}
		}
		list.Add(_number);
		return list;
	}

	public static int modNoNegative(int _nb, int _mod)
	{
		int num = _nb % _mod;
		if (num >= 0)
		{
			return num;
		}
		int num2 = Mathf.CeilToInt(Mathf.Abs((float)_nb) / (float)_mod);
		return num + num2 * _mod;
	}

	public static bool between(this int _number, int _min, int _max, bool _inclusive = false)
	{
		if (!_inclusive)
		{
			if (_number > _min)
			{
				return _number < _max;
			}
			return false;
		}
		if (_number >= _min)
		{
			return _number <= _max;
		}
		return false;
	}

	public static int intPow(this int x, uint pow)
	{
		int num = 1;
		while (pow != 0)
		{
			if ((pow & 1) == 1)
			{
				num *= x;
			}
			x *= x;
			pow >>= 1;
		}
		return num;
	}
}
