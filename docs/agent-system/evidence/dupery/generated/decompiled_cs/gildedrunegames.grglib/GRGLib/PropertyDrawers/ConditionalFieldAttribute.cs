using System;
using UnityEngine;

namespace GRGLib.PropertyDrawers;

[AttributeUsage(AttributeTargets.Field)]
public class ConditionalFieldAttribute : PropertyAttribute
{
	public readonly ConditionalData Data;

	public bool IsSet => Data != null;

	protected ConditionalFieldAttribute(ConditionalData _data)
	{
		Data = _data;
	}

	public ConditionalFieldAttribute(string fieldToCheck, bool inverse, params object[] compareValues)
	{
		Data = new ValueConditionalData(fieldToCheck, inverse, compareValues);
	}

	public ConditionalFieldAttribute(string fieldToCheck, params object[] compareValues)
	{
		Data = new ValueConditionalData(fieldToCheck, _inverse: false, compareValues);
	}

	public ConditionalFieldAttribute(string fieldToCheck)
	{
		Data = new ValueConditionalData(fieldToCheck, false, true);
	}
}
