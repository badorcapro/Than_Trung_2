using System;
using UnityEngine;

namespace GRGLib.Extensions.Vector;

public static class VectorExtensions
{
	public static Vector2 addVector3(this Vector2 _v2, Vector3 _v3)
	{
		return new Vector2(_v2.x + _v3.x, _v2.y + _v3.y);
	}

	public static Vector2 multiply(this Vector2 _a, Vector2 _b)
	{
		return new Vector2(_a.x * _b.x, _a.y * _b.y);
	}

	public static Vector2 xyMultiply(this Vector3 _a, Vector3 _b)
	{
		return new Vector2(_a.x * _b.x, _a.y * _b.y);
	}

	public static Vector2 xy(this Vector3 _vector)
	{
		return new Vector2(_vector.x, _vector.y);
	}

	public static Vector2Int xy(this Vector3Int _vector)
	{
		return new Vector2Int(_vector.x, _vector.y);
	}

	public static Vector2 polarToCartesian(this Vector2 _polar_coords)
	{
		return polarToCartesian(_polar_coords.x, _polar_coords.y);
	}

	public static Vector2 polarToCartesian(float _radius, float _theta)
	{
		return new Vector2(_radius * Mathf.Cos(_theta * (MathF.PI / 180f)), _radius * Mathf.Sin(_theta * (MathF.PI / 180f)));
	}

	public static Vector2 cartesianToPolar(this Vector2 _cartesian_coords)
	{
		return cartesianToPolar(_cartesian_coords.x, _cartesian_coords.y);
	}

	public static Vector2 cartesianToPolar(float _x, float _y)
	{
		return new Vector2(Mathf.Sqrt(_x * _x + _y * _y), Mathf.Atan(_y / _x));
	}

	public static Vector2 abs(this Vector2 _v)
	{
		return new Vector2(Mathf.Abs(_v.x), Mathf.Abs(_v.y));
	}

	public static Vector2 setX(this Vector2 _in, float _x)
	{
		return new Vector2(_x, _in.y);
	}

	public static Vector2 setY(this Vector2 _in, float _y)
	{
		return new Vector2(_in.x, _y);
	}

	public static Vector2Int abs(this Vector2Int _v)
	{
		return new Vector2Int(Mathf.Abs(_v.x), Mathf.Abs(_v.y));
	}

	public static Vector2 toVector2(this Vector2Int _vector)
	{
		return new Vector2(_vector.x, _vector.y);
	}

	public static Vector2Int toVector2Int(this Vector2 _vector)
	{
		return _vector.toVector2Int(Mathf.RoundToInt);
	}

	public static Vector2Int toVector2Int(this Vector2 _vector, Func<float, int> _conversion_method)
	{
		return new Vector2Int(_conversion_method(_vector.x), _conversion_method(_vector.y));
	}

	public static Vector3 addVector2(this Vector3 _v3, Vector2 _v2)
	{
		return new Vector3(_v3.x + _v2.x, _v3.y + _v2.y, _v3.z);
	}

	public static Vector3 multiply(this Vector3 _a, Vector3 _b)
	{
		return new Vector3(_a.x * _b.x, _a.y * _b.y, _a.z * _b.z);
	}

	public static Vector3 divide(this Vector3 _a, Vector3 _divide_by)
	{
		return new Vector3(_a.x / _divide_by.x, _a.y / _divide_by.y, _a.z / _divide_by.z);
	}

	public static Vector3 clamp(this Vector3 _value, Vector3 _min, Vector3 _max)
	{
		return new Vector3(Mathf.Clamp(_value.x, _min.x, _max.x), Mathf.Clamp(_value.y, _min.y, _max.y), Mathf.Clamp(_value.z, _min.z, _max.z));
	}

	public static Vector3 clampXY(this Vector3 _value, Vector3 _min, Vector3 _max)
	{
		return new Vector3(Mathf.Clamp(_value.x, _min.x, _max.x), Mathf.Clamp(_value.y, _min.y, _max.y), _value.z);
	}

	public static Vector3 Rotate(this Vector3 v, float degrees)
	{
		float num = Mathf.Sin(degrees * (MathF.PI / 180f));
		float num2 = Mathf.Cos(degrees * (MathF.PI / 180f));
		float x = v.x;
		float y = v.y;
		v.x = num2 * x - num * y;
		v.y = num * x + num2 * y;
		return v;
	}

	public static Vector3 abs(this Vector3 _v)
	{
		return new Vector3(Mathf.Abs(_v.x), Mathf.Abs(_v.y), Mathf.Abs(_v.z));
	}

	public static Vector3 setX(this Vector3 _in, float _x)
	{
		return new Vector3(_x, _in.y, _in.z);
	}

	public static Vector3 setY(this Vector3 _in, float _y)
	{
		return new Vector3(_in.x, _y, _in.z);
	}

	public static Vector3 setZ(this Vector3 _in, float _z)
	{
		return new Vector3(_in.x, _in.y, _z);
	}

	public static Vector3 addX(this Vector3 _vector, float _add)
	{
		return _vector + new Vector3(_add, 0f, 0f);
	}

	public static Vector3 addY(this Vector3 _vector, float _add)
	{
		return _vector + new Vector3(0f, _add, 0f);
	}

	public static Vector3 addZ(this Vector3 _vector, float _add)
	{
		return _vector + new Vector3(0f, 0f, _add);
	}

	public static Vector3 toVector3(this Vector3Int _vector)
	{
		return new Vector3(_vector.x, _vector.y, _vector.z);
	}

	public static Vector3 toVector3(this Vector2 _vector, float _z = 0f)
	{
		return new Vector3(_vector.x, _vector.y, _z);
	}

	public static Vector3Int toVector3Int(this Vector3 _vector)
	{
		return _vector.toVector3Int(Mathf.RoundToInt);
	}

	public static Vector3Int toVector3Int(this Vector3 _vector, Func<float, int> _conversion_method)
	{
		return new Vector3Int(_conversion_method(_vector.x), _conversion_method(_vector.y), _conversion_method(_vector.z));
	}

	public static Vector3Int toVector3Int(this Vector2Int _vector, int _z = 0)
	{
		return new Vector3Int(_vector.x, _vector.y, _z);
	}

	public static float toDegrees(this Vector2 _v)
	{
		return Vector2.SignedAngle(Vector2.right, _v);
	}
}
