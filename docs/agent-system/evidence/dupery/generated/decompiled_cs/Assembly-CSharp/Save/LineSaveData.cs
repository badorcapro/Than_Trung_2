using System;
using System.Collections.Generic;
using UnityEngine;

namespace Save;

[Serializable]
public struct LineSaveData
{
	public static int max_points_save = 8000;

	public List<Vector2> points;

	public List<int> invisible;

	public Color line_colour;

	public LineSaveData(List<Vector2> _points, List<int> _invisible, Color _colour)
	{
		points = _points;
		invisible = _invisible;
		line_colour = _colour;
	}
}
