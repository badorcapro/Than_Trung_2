using System.Collections.Generic;
using GRGLib.Extensions.Bezier;
using UnityEngine;

namespace GRGLib.Mono;

[AddComponentMenu("GRGLib/Bezier/SplineHandler")]
public class SplineHandler : MonoBehaviour
{
	[Header("Spline Settings")]
	public bool loops;

	[SerializeField]
	private List<SplinePoint> spline_points;

	public List<Vector3> getCubicCurve(int _precision_per_segment = 100)
	{
		return spline_points.CubicBezier(loops, _precision_per_segment);
	}

	public List<SplinePoint> getBasePoints()
	{
		return spline_points;
	}

	public void setPoints(List<SplinePoint> _points)
	{
		spline_points = _points;
	}
}
