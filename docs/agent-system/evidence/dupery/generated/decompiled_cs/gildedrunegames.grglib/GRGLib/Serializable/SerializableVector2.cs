using System;
using UnityEngine;

namespace GRGLib.Serializable;

[Serializable]
public struct SerializableVector2
{
	public float x;

	public float y;

	public SerializableVector2(Vector2 _v)
	{
		x = _v.x;
		y = _v.y;
	}

	public SerializableVector2(Vector3 _v)
	{
		x = _v.x;
		y = _v.y;
	}

	public Vector2 unserialize()
	{
		return new Vector2(x, y);
	}

	public Vector3 unserializeToVector3()
	{
		return new Vector3(x, y, 0f);
	}
}
