using System;
using GRGLib.Extensions.Numbers;

namespace GRGLib.PropertyDrawers;

[AttributeUsage(AttributeTargets.Field)]
public class NumberConditionalAttribute : ConditionalFieldAttribute
{
	public NumberConditionalAttribute(string fieldToCheck, NumberComparaison method, int _compare_to)
		: base(new NumberConditionalData(fieldToCheck, _inverse: false, method, _compare_to))
	{
	}

	public NumberConditionalAttribute(string fieldToCheck, NumberComparaison method, float _compare_to)
		: base(new NumberConditionalData(fieldToCheck, _inverse: false, method, _compare_to))
	{
	}
}
