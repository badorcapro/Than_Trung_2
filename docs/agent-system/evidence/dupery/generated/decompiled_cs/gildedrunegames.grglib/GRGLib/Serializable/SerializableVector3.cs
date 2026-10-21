using System;
using UnityEngine;

namespace GRGLib.Serializable;

[Serializable]
public struct SerializableVector3
{
	public float x;

	public float y;

	public float z;

	public SerializableVector3(Vector3 _v)
	{
		x = _v.x;
		y = _v.y;
		z = _v.z;
	}

	public Vector3 toVector3()
	{
		return new Vector3(x, y, z);
	}
}
