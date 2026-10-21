using System;
using UnityEngine;

namespace Leads;

[Serializable]
public class StampInfo
{
	public StampReference stamp_reference;

	public Vector2 position = new Vector2(0f, 0f);

	public float rotation;

	public bool faded;

	public StampInfo()
	{
	}

	public StampInfo(StampReference _ref, Vector2 _position, float _rotation)
	{
		stamp_reference = _ref;
		position = _position;
		rotation = _rotation;
	}
}
