using System;

namespace GRGLib.Serializable;

[Serializable]
public struct STupple<T, T2>
{
	public T Item1;

	public T2 Item2;

	public STupple(T _type, T2 _type_2)
	{
		Item1 = _type;
		Item2 = _type_2;
	}

	public static STupple<T, T2> StaticTypeType(T _type, T2 _type_2)
	{
		return new STupple<T, T2>(_type, _type_2);
	}

	public (T, T2) get()
	{
		return (Item1, Item2);
	}
}
[Serializable]
public struct STupple<T, T2, T3>
{
	public T Item1;

	public T2 Item2;

	public T3 Item3;

	public STupple(T _i1, T2 _i2, T3 _i3)
	{
		Item1 = _i1;
		Item2 = _i2;
		Item3 = _i3;
	}

	public static STupple<T, T2, T3> StaticSTupple(T _i1, T2 _i2, T3 _i3)
	{
		return new STupple<T, T2, T3>(_i1, _i2, _i3);
	}

	public (T, T2, T3) get()
	{
		return (Item1, Item2, Item3);
	}
}
