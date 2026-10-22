using System.Collections;
using System.Collections.Generic;
using System.Linq;
using GRGLib.Coroutines;
using GRGLib.Extensions.Bezier;
using GRGLib.UI;
using UnityEngine;
using UnityEngine.UI;

namespace Visual;

public class RevealLine : AdvancedUILineRenderer
{
	[Header("Reveal Line Settings")]
	[SerializeField]
	private Image arrow_point;

	private CoroutineRunner line_runner;

	private CoroutineRunner arrowhead_runner;

	public void makeLine(Vector2 _from, Vector2 _to, Color _colour)
	{
		line_runner = new CoroutineRunner(this);
		arrowhead_runner = new CoroutineRunner(this);
		color = _colour;
		arrow_point.color = new Color(_colour.r, _colour.g, _colour.b, 0f);
		if (_from.x == _to.x || _from.y == _to.y)
		{
			setPoints(getStraightLinePoints(_from, _to, 100));
		}
		else
		{
			setPoints((from _v in BezierCurve.Bezier2D(100, _from, new Vector2(_from.x, _to.y), _to)
				select new Vector2(_v.x, _v.y)).ToList());
		}
		makeLineInvisible();
		arrowhead_runner.run(arrow_point.fade(1f, 0.15f, CoroutineExtensions.easeInOutFunc));
		line_runner.run(drawLine(0.35f));
	}

	private List<Vector2> getStraightLinePoints(Vector2 _start, Vector2 _end, int _precision)
	{
		List<Vector2> list = new List<Vector2>();
		Vector2 vector = _end - _start;
		for (int i = 0; i < _precision; i++)
		{
			list.Add(_start + vector * ((float)i / (float)_precision));
		}
		list.Add(_end);
		return list;
	}

	private IEnumerator drawLine(float _duration)
	{
		float e = 0f;
		int total_points = points.Count;
		int last_point = 0;
		while (e < _duration)
		{
			int num = Mathf.CeilToInt((float)total_points * CoroutineExtensions.easeInOutFunc(e / _duration));
			for (int i = last_point; i < num; i++)
			{
				addVisiblePoint(i);
			}
			last_point = num;
			if (num > 0 && num < points.Count)
			{
				arrow_point.transform.localPosition = points[num];
				arrow_point.transform.localEulerAngles = new Vector3(0f, 0f, Vector2.SignedAngle(Vector2.up, points[num] - points[num - 1]));
			}
			e += Time.deltaTime;
			yield return null;
		}
	}

	public void destroyLine()
	{
		arrowhead_runner.run(arrow_point.fade(0f, 0.1f, CoroutineExtensions.easeInOutFunc));
		line_runner.run(destroyLine(0.15f));
	}

	private IEnumerator destroyLine(float _duration)
	{
		float e = 0f;
		int total_points = points.Count;
		int last_point = total_points;
		while (e < _duration)
		{
			int num = total_points - Mathf.CeilToInt((float)total_points * CoroutineExtensions.easeInOutFunc(e / _duration));
			for (int num2 = last_point; num2 > num; num2--)
			{
				addInvisiblePoint(num2);
				refreshVertices();
			}
			last_point = num;
			if (num > 0 && num < points.Count)
			{
				arrow_point.transform.localPosition = points[num];
				arrow_point.transform.localEulerAngles = new Vector3(0f, 0f, Vector2.SignedAngle(Vector2.up, points[num] - points[num - 1]));
			}
			e += Time.deltaTime;
			yield return null;
		}
		Object.Destroy(base.gameObject);
	}
}
