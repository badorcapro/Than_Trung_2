using System;
using UnityEngine;

namespace GRGLib.Save;

[Serializable]
public struct SaveFile<T>
{
	public string version;

	public T data;

	public SaveFile(T _data)
	{
		data = _data;
		version = Application.version;
	}
}
