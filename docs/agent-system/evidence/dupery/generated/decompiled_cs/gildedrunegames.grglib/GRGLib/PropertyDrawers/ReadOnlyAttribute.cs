using System;
using UnityEngine;

namespace GRGLib.PropertyDrawers;

[AttributeUsage(AttributeTargets.Field)]
public class ReadOnlyAttribute : PropertyAttribute
{
	public ReadOnlyData data;

	public ReadOnlyAttribute()
	{
		data = new ReadOnlyData();
	}

	public ReadOnlyAttribute(string fieldToCheck, bool inverse, params object[] compareValues)
	{
		data = new ConditionalReadOnlyData(new ValueConditionalData(fieldToCheck, inverse, compareValues));
	}

	public ReadOnlyAttribute(string fieldToCheck, params object[] compareValues)
	{
		data = new ConditionalReadOnlyData(new ValueConditionalData(fieldToCheck, _inverse: false, compareValues));
	}

	public ReadOnlyAttribute(string fieldToCheck)
	{
		data = new ConditionalReadOnlyData(new ValueConditionalData(fieldToCheck, false, true));
	}

	public ReadOnlyAttribute(ConditionalData _data)
	{
		data = new ConditionalReadOnlyData(_data);
	}
}
