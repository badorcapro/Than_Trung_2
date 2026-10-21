using System;

namespace GRGLib.PropertyDrawers;

public class ObjectTypeConditionalData : ConditionalData
{
	private readonly TypeConditionalCheck check_type;

	private readonly Type[] types_to_compare;

	public ObjectTypeConditionalData(bool _inverse = false, TypeConditionalCheck _check_type = TypeConditionalCheck.EXACT, params Type[] _compare)
		: base("", _inverse)
	{
		check_type = _check_type;
		types_to_compare = _compare;
	}
}
