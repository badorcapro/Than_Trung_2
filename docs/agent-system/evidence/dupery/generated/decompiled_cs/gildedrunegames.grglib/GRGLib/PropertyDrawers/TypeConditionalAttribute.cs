using System;

namespace GRGLib.PropertyDrawers;

[AttributeUsage(AttributeTargets.Field)]
public class TypeConditionalAttribute : ConditionalFieldAttribute
{
	public TypeConditionalAttribute(string fieldToCheck, TypeConditionalCheck _check_type, bool _inverse, params Type[] compareTypes)
		: base(new TypeConditionalData(fieldToCheck, _inverse, _check_type, compareTypes))
	{
	}

	public TypeConditionalAttribute(string fieldToCheck, TypeConditionalCheck _check_type, params Type[] compareType)
		: base(new TypeConditionalData(fieldToCheck, _inverse: false, _check_type, compareType))
	{
	}

	public TypeConditionalAttribute(string fieldToCheck, params Type[] compareType)
		: base(new TypeConditionalData(fieldToCheck, _inverse: false, TypeConditionalCheck.EXACT, compareType))
	{
	}
}
