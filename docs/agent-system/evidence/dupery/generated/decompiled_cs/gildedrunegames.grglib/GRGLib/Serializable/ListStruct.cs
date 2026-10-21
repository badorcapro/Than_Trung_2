using System;
using System.Collections.Generic;

namespace GRGLib.Serializable;

[Serializable]
public struct ListStruct<T>
{
	public List<T> list;

	public int Count => list.Count;

	public T this[int _i] => list[_i];

	public ListStruct(List<T> _list)
	{
		list = _list;
	}
}
