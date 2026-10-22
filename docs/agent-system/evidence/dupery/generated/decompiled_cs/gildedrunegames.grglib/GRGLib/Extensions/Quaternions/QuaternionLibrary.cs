using UnityEngine;

namespace GRGLib.Extensions.Quaternions;

public static class QuaternionLibrary
{
	public static Quaternion lookRotation2D(this Vector2 _center, Vector2 _target)
	{
		return new Vector3(_center.x, _center.y, 0f).lookRotation2D(new Vector3(_target.x, _target.y));
	}

	public static Quaternion lookRotation2DInverse(this Vector2 _center, Vector2 _target)
	{
		return new Vector3(_center.x, _center.y, 0f).lookRotation2DInverse(new Vector3(_target.x, _target.y));
	}

	public static Quaternion lookRotation2D(this Vector3 _center, Vector3 _target)
	{
		return (_target - _center).normalized.lookRotation2D();
	}

	public static Quaternion lookRotation2DInverse(this Vector3 _center, Vector3 _target)
	{
		return (_target - _center).normalized.lookRotation2DInverse();
	}

	public static Quaternion lookRotation2D(this Vector3 _aim)
	{
		Vector3 upwards = Quaternion.Euler(0f, 0f, 90f) * _aim;
		return Quaternion.LookRotation(Vector3.forward, upwards);
	}

	public static Quaternion lookRotation2DInverse(this Vector3 _aim)
	{
		Vector3 upwards = Quaternion.Euler(0f, 0f, 90f) * _aim;
		return Quaternion.LookRotation(Vector3.back, upwards);
	}
}
