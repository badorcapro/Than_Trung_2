using System.Collections.Generic;
using GRGLib.Extensions.Collections;
using UnityEngine;
using UnityEngine.UI;

namespace GRGLib.UI;

public class AdvancedUILineRenderer : UILineRenderer
{
	[Header("Optional References")]
	[SerializeField]
	protected Image start_image;

	[SerializeField]
	protected Image end_image;

	protected HashSet<int> invisible_points = new HashSet<int>();

	public bool has_start_image => start_image != null;

	public bool has_end_image => end_image != null;

	public bool has_any_image
	{
		get
		{
			if (!has_start_image)
			{
				return has_end_image;
			}
			return true;
		}
	}

	protected void enableStartPoint(bool _true = true)
	{
		if (has_start_image)
		{
			start_image.enabled = _true;
		}
	}

	protected void enableEndPoint(bool _true = true)
	{
		if (has_end_image)
		{
			end_image.enabled = _true;
		}
	}

	protected void setStartImage(Vector2 _position)
	{
		if (has_start_image)
		{
			start_image.transform.localPosition = _position;
		}
	}

	protected void setEndImage(Vector2 _position)
	{
		if (has_end_image)
		{
			end_image.transform.localPosition = _position;
		}
	}

	protected void setImagesColour(Color _colour)
	{
		if (has_start_image)
		{
			start_image.color = _colour;
		}
		if (has_end_image)
		{
			end_image.color = _colour;
		}
	}

	public override void setPoints(List<Vector2> _points)
	{
		base.setPoints(_points);
		setStartImage(_points[0]);
		setEndImage(_points.last());
	}

	public override void addPoint(Vector2 _point)
	{
		base.addPoint(_point);
		setEndImage(_point);
	}

	public override void addPoints(List<Vector2> _points)
	{
		base.addPoints(_points);
		setEndImage(_points.last());
	}

	public void makeLineVisible()
	{
		invisible_points.Clear();
		enableStartPoint();
		enableEndPoint();
	}

	public void addVisiblePoint(int _point)
	{
		invisible_points.Remove(_point);
		if (_point == 0)
		{
			enableStartPoint();
		}
		else if (_point == points.Count - 1)
		{
			enableEndPoint();
		}
		refreshVertices();
	}

	public void makeLineInvisible()
	{
		enableStartPoint(_true: false);
		enableEndPoint(_true: false);
		for (int i = 0; i < points.Count; i++)
		{
			invisible_points.add(i);
		}
	}

	public void addInvisiblePoint(int _point)
	{
		invisible_points.Add(_point);
		if (_point == 0)
		{
			enableStartPoint(_true: false);
		}
		else if (_point == points.Count - 1)
		{
			enableEndPoint(_true: false);
		}
	}

	public bool isAllInvisible()
	{
		return invisible_points.Count == points.Count;
	}

	protected override Color getPointColour(int _point, float _t)
	{
		Color pointColour = base.getPointColour(_point, _t);
		if (!invisible_points.Contains(_point))
		{
			return pointColour;
		}
		pointColour.a = 0f;
		return pointColour;
	}
}
