using System;
using FMOD;

namespace FMODUnity;

[Serializable]
public struct EventReference
{
	public GUID Guid;

	public bool IsNull => Guid.IsNull;

	public override string ToString()
	{
		return Guid.ToString();
	}
}
