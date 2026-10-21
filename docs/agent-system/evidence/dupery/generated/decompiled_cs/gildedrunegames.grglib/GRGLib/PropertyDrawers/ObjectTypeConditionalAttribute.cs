using System;

namespace GRGLib.PropertyDrawers;

[AttributeUsage(AttributeTargets.Field)]
public class ObjectTypeConditionalAttribute : ConditionalFieldAttribute
{
	public ObjectTypeConditionalAttribute(params Type[] _type)
		: base(new ObjectTypeConditionalData(_inverse: false, TypeConditionalCheck.EXACT, _type))
	{
	}

	public ObjectTypeConditionalAttribute(TypeConditionalCheck _method, params Type[] _type)
		: base(new ObjectTypeConditionalData(_inverse: false, _method, _type))
	{
	}

	public ObjectTypeConditionalAttribute(bool _inverse, TypeConditionalCheck _method, params Type[] _type)
		: base(new ObjectTypeConditionalData(_inverse, _method, _type))
	{
	}
}
