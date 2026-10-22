using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Visual.Drawing;

public static class RTDrawingHelper
{
	public static List<Vector2Int> makeSquare(this Vector2Int _center, int _radius)
	{
		List<Vector2Int> list = new List<Vector2Int>();
		for (int i = _center.x - Mathf.FloorToInt(_radius); i < _center.x + Mathf.FloorToInt(_radius); i++)
		{
			for (int j = _center.y - Mathf.FloorToInt(_radius); j < _center.y + Mathf.FloorToInt(_radius); j++)
			{
				list.Add(new Vector2Int(i, j));
			}
		}
		return list;
	}

	public static List<Vector2Int> makeRectangle(this Vector2Int _bottom_left, Vector2Int _top_right)
	{
		List<Vector2Int> list = new List<Vector2Int>();
		for (int i = _bottom_left.x; i <= _top_right.x; i++)
		{
			for (int j = _bottom_left.y; j <= _top_right.y; j++)
			{
				list.Add(new Vector2Int(i, j));
			}
		}
		return list;
	}

	public static List<Vector2Int> makeLine(this Vector2Int _pos_1, Vector2Int _pos_2, int _radius)
	{
		Vector2Int vector2Int = _pos_2 - _pos_1;
		if (Mathf.Abs(vector2Int.x) >= Mathf.Abs(vector2Int.y))
		{
			return ((vector2Int.x > 0) ? _pos_1 : _pos_2).makeLineHorizontal((vector2Int.x > 0) ? _pos_2 : _pos_1, _radius);
		}
		return ((vector2Int.y > 0) ? _pos_1 : _pos_2).makeLineVertical((vector2Int.y > 0) ? _pos_2 : _pos_1, _radius);
	}

	private static List<Vector2Int> makeLineVertical(this Vector2Int _bot_center, Vector2Int _top_center, int _radius)
	{
		List<Vector2Int> list = new List<Vector2Int>();
		Vector2Int vector2Int = _top_center - _bot_center;
		float num = (float)vector2Int.x / (float)vector2Int.y;
		for (int i = 0; i <= vector2Int.y; i++)
		{
			int num2 = Mathf.RoundToInt(num * (float)i);
			for (int j = -_radius; j < _radius; j++)
			{
				int x = num2 + j;
				list.Add(_bot_center + new Vector2Int(x, i));
			}
		}
		return list;
	}

	private static List<Vector2Int> makeLineHorizontal(this Vector2Int _left_center, Vector2Int _right_center, int _radius)
	{
		List<Vector2Int> list = new List<Vector2Int>();
		Vector2Int vector2Int = _right_center - _left_center;
		float num = (float)vector2Int.y / (float)vector2Int.x;
		for (int i = 0; i <= vector2Int.x; i++)
		{
			int num2 = Mathf.RoundToInt(num * (float)i);
			for (int j = -_radius; j < _radius; j++)
			{
				int y = num2 + j;
				list.Add(_left_center + new Vector2Int(i, y));
			}
		}
		return list;
	}

	public static List<Vector2Int> makeCircle(this Vector2Int _center, int _radius)
	{
		return (from _p in _center.makeSquare(_radius)
			where Mathf.Sqrt((_p.x - _center.x) * (_p.x - _center.x) + (_p.y - _center.y) * (_p.y - _center.y)) < (float)_radius
			select _p).ToList();
	}
}
