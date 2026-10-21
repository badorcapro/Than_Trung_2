using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace GRGLib.Extensions.Bezier;

public static class BezierCurve
{
	public static List<Vector3> CubicBezier(this List<SplinePoint> _points, bool _loops = false, int _precision_per_segment = 100)
	{
		List<Vector3> list = new List<Vector3>();
		for (int i = 1; i < _points.Count; i++)
		{
			list.AddRange(CubicBezierCurve(_points[i - 1].point, _points[i - 1].constraint_after, _points[i].constraint_before, _points[i].point, _precision_per_segment));
		}
		if (_loops)
		{
			list.AddRange(CubicBezierCurve(_points[_points.Count - 1].point, _points[_points.Count - 1].constraint_after, _points[0].constraint_before, _points[0].point, _precision_per_segment));
		}
		return list;
	}

	public static Vector3[] CubicBezierCurve(Vector3 _p0, Vector3 _p1, Vector3 _p2, Vector3 _p3, int _precision)
	{
		Vector3[] array = new Vector3[_precision + 1];
		float num = 0f;
		float num2 = 1f / (float)_precision;
		for (int i = 0; i < _precision; i++)
		{
			float num3 = Mathf.Pow(num, 2f);
			float num4 = Mathf.Pow(num, 3f);
			Vector3 vector = Mathf.Pow(1f - num, 3f) * _p0 + 3f * Mathf.Pow(1f - num, 2f) * num * _p1 + 3f * (1f - num) * num3 * _p2 + num4 * _p3;
			array[i] = vector;
			num += num2;
		}
		array[_precision] = _p3;
		return array;
	}

	public static Vector3[] Bezier2D(int _precision, params Vector3[] _points)
	{
		return _points.ToList().Bezier2D(_precision);
	}

	public static Vector3[] Bezier2D(this List<Vector3> _initial_points, int _precision)
	{
		int count = _initial_points.Count;
		Vector3[] array = new Vector3[_precision];
		float num = 0f;
		float num2 = 1f / (float)(_precision - 1);
		for (int i = 0; i < _precision; i++)
		{
			if (1.0 - (double)num < 5E-06)
			{
				num = 1f;
			}
			Vector2 vector = _initial_points[0];
			for (int j = 0; j < count; j++)
			{
				Vector3 vector2 = _initial_points[j] - _initial_points[0];
				float num3 = Bernstein(count - 1, j, num);
				vector.x += num3 * vector2.x;
				vector.y += num3 * vector2.y;
			}
			num += num2;
			array[i] = vector;
		}
		return array;
	}

	public static Vector3 BezierPoint2D(this List<Vector3> _initial_points, float _t)
	{
		int count = _initial_points.Count;
		Vector2 vector = new Vector2(0f, 0f);
		for (int i = 0; i < count; i++)
		{
			float num = Bernstein(count - 1, i, _t);
			vector.x += num * _initial_points[i].x;
			vector.y += num * _initial_points[i].y;
		}
		return vector;
	}

	private static float Bernstein(int n, int i, float t)
	{
		return Binomial(n, i) * Mathf.Pow(t, i) * Mathf.Pow(1f - t, n - i);
	}

	private static float Binomial(int n, int i)
	{
		return GetFactorials(n) / (GetFactorials(i) * GetFactorials(n - i));
	}

	private static float GetFactorials(int n)
	{
		return CalculateFactorial(n);
	}

	private static float CalculateFactorial(int n)
	{
		if (n < 2)
		{
			return 1f;
		}
		float num = n;
		int num2 = n - 1;
		while (n > 1)
		{
			num *= (float)num2;
			n--;
		}
		return num;
	}
}
