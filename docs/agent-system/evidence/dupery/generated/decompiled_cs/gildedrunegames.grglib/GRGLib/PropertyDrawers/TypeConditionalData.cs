using System;

namespace GRGLib.PropertyDrawers;

public class TypeConditionalData : ConditionalData
{
	private readonly TypeConditionalCheck check_type;

	private readonly Type[] types_to_compare;

	public TypeConditionalData(string _field, bool _inverse = false, TypeConditionalCheck _check_type = TypeConditionalCheck.EXACT, params Type[] _compare)
		: base(_field, _inverse)
	{
		check_type = _check_type;
		types_to_compare = _compare;
	}
}
