using System;

namespace GRGLib.Extensions.Numbers;

public static class FloatExtension
{
	public static bool compareFloat(this float _value, NumberComparaison _comparator, float _to_compare)
	{
		return _comparator switch
		{
			NumberComparaison.BELOW => _value < _to_compare, 
			NumberComparaison.ABOVE => _value > _to_compare, 
			NumberComparaison.EXACT => _value == _to_compare, 
			NumberComparaison.EXACT_AND_ABOVE => _value >= _to_compare, 
			NumberComparaison.EXACT_AND_BELOW => _value <= _to_compare, 
			_ => throw new ArgumentException($"Cannot find comparator: {_comparator}. In FloatExtension.compareFloat()"), 
		};
	}
}
