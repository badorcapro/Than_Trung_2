using System;
using System.Linq;

namespace GRGLib.Extensions;

public static class GenericExtensions
{
	public static bool isNullable<T>(this T _obj)
	{
		if (_obj == null)
		{
			return true;
		}
		return typeof(T).isNullable();
	}

	public static bool isNullable(this Type _type)
	{
		if (!_type.IsValueType)
		{
			return true;
		}
		if (Nullable.GetUnderlyingType(_type) != null)
		{
			return true;
		}
		return false;
	}

	public static bool equalToAny<T>(this T _val, params T[] _to_check)
	{
		return _to_check.ToList().Exists((T e) => e.Equals(_val));
	}

	public static bool isSubclassOfAny(this Type _type, params Type[] _to_check)
	{
		foreach (Type c in _to_check)
		{
			if (_type.IsSubclassOf(c))
			{
				return true;
			}
		}
		return false;
	}
}
