namespace FMOD.Studio;

public struct USER_PROPERTY
{
	public StringWrapper name;

	public USER_PROPERTY_TYPE type;

	private Union_IntBoolFloatString value;

	public int intValue()
	{
		if (type != 0)
		{
			return -1;
		}
		return value.intvalue;
	}

	public bool boolValue()
	{
		if (type != USER_PROPERTY_TYPE.BOOLEAN)
		{
			return false;
		}
		return value.boolvalue;
	}

	public float floatValue()
	{
		if (type != USER_PROPERTY_TYPE.FLOAT)
		{
			return -1f;
		}
		return value.floatvalue;
	}

	public string stringValue()
	{
		if (type != USER_PROPERTY_TYPE.STRING)
		{
			return "";
		}
		return value.stringvalue;
	}
}
