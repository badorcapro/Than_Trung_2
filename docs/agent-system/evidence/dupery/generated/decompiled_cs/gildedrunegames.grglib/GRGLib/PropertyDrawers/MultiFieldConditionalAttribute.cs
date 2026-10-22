using System;

namespace GRGLib.PropertyDrawers;

[AttributeUsage(AttributeTargets.Field)]
public class MultiFieldConditionalAttribute : ConditionalFieldAttribute
{
	public MultiFieldConditionalAttribute(params string[] _fields)
		: base(new MultipleValueConditionalData(true, _all_match: true, _inverse: false, _fields))
	{
	}

	public MultiFieldConditionalAttribute(object _compare, params string[] _fields)
		: base(new MultipleValueConditionalData(_compare, _all_match: true, _inverse: false, _fields))
	{
	}

	public MultiFieldConditionalAttribute(object _compare, bool _all_match, params string[] _fields)
		: base(new MultipleValueConditionalData(_compare, _all_match, _inverse: false, _fields))
	{
	}

	public MultiFieldConditionalAttribute(object _compare, bool _all_match, bool _inverse, params string[] _fields)
		: base(new MultipleValueConditionalData(_compare, _all_match, _inverse, _fields))
	{
	}
}
