using System;

[AttributeUsage(AttributeTargets.Field)]
public class PortTypeOverrideAttribute : Attribute
{
	public Type type;

	public PortTypeOverrideAttribute(Type type)
	{
		this.type = type;
	}
}
